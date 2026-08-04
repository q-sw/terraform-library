package test

import (
	"fmt"
	"os"
	"os/exec"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/hashicorp/vault/api"
	"github.com/stretchr/testify/assert"
)

func TestVaultPkiModule(t *testing.T) {
	t.Parallel()

	vaultAddr := os.Getenv("VAULT_ADDR")
	vaultToken := os.Getenv("VAULT_TOKEN")
	runDocker := false
	containerName := "vault-terratest-dev"

	// Si aucune instance de Vault n'est spécifiée, on lance un conteneur éphémère
	if vaultAddr == "" {
		vaultAddr = "http://127.0.0.1:8200"
		vaultToken = "root"
		runDocker = true

		t.Log("VAULT_ADDR non défini. Lancement d'un conteneur Docker Vault de test...")
		
		// S'assurer qu'un conteneur avec le même nom n'existe plus
		exec.Command("docker", "rm", "-f", containerName).Run()

		cmd := exec.Command("docker", "run", "-d",
			"--name", containerName,
			"-p", "8200:8200",
			"-e", "VAULT_DEV_ROOT_TOKEN_ID=root",
			"-e", "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200",
			"hashicorp/vault:1.15.0",
		)
		if err := cmd.Run(); err != nil {
			t.Fatalf("Impossible de démarrer le conteneur Vault de test: %v", err)
		}

		// Laisser le temps à Vault de démarrer
		time.Sleep(3 * time.Second)
	}

	if runDocker {
		defer func() {
			t.Log("Arrêt et suppression du conteneur Vault...")
			exec.Command("docker", "rm", "-f", containerName).Run()
		}()
	}

	// Configuration de Terraform
	primaryCAName   := "test-pki-root"
	secondaryCAName := "test-pki-sub-web"
	roleName        := "test-web-servers"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		EnvVars: map[string]string{
			"VAULT_ADDR":  vaultAddr,
			"VAULT_TOKEN": vaultToken,
		},
		Vars: map[string]interface{}{
			"pki_mode": "internal",
			"primary_ca": map[string]interface{}{
				"name":         primaryCAName,
				"description":  "Root CA de Test",
				"common_name":  "Terratest Root CA",
				"organization": "Terratest Corp",
				"country":      "FR",
			},
			"secondary_cas": map[string]interface{}{
				secondaryCAName: map[string]interface{}{
					"description":     "Intermediate CA de Test",
					"common_name":     "Terratest Intermediate CA",
					"organization":    "Terratest Corp",
					"role_name":       roleName,
					"allowed_domains": []string{"test.lan", "localhost"},
				},
			},
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Connexion au client Vault
	config := api.DefaultConfig()
	config.Address = vaultAddr
	client, err := api.NewClient(config)
	if err != nil {
		t.Fatalf("Impossible de créer le client Vault: %v", err)
	}
	client.SetToken(vaultToken)

	// Validation des mounts
	sys := client.Sys()
	mounts, err := sys.ListMounts()
	if err != nil {
		t.Fatalf("Impossible de lister les mounts Vault: %v", err)
	}

	primaryPath := fmt.Sprintf("%s/", primaryCAName)
	primaryMount, exists := mounts[primaryPath]
	assert.True(t, exists, "Le mount de la CA primaire devrait exister")
	assert.Equal(t, "pki", primaryMount.Type)

	secondaryPath := fmt.Sprintf("%s/", secondaryCAName)
	secondaryMount, exists := mounts[secondaryPath]
	assert.True(t, exists, "Le mount de la CA secondaire devrait exister")
	assert.Equal(t, "pki", secondaryMount.Type)

	// Validation du rôle PKI
	roleEndpoint := fmt.Sprintf("v1/%s/roles/%s", secondaryCAName, roleName)
	req := client.NewRequest("GET", "/"+roleEndpoint)
	resp, err := client.RawRequest(req)
	if err != nil {
		t.Errorf("Impossible d'interroger le rôle PKI : %v", err)
	} else {
		assert.Equal(t, 200, resp.StatusCode)
	}
}
