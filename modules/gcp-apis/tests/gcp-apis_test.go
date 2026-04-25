package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"google.golang.org/api/serviceusage/v1"
)

// Helper pour vérifier l'état réel des APIs via le SDK Google
func verifyApisStatus(t *testing.T, projectID string, apis []string, expectedEnabled bool) {
	ctx := context.Background()
	service, err := serviceusage.NewService(ctx)
	if err != nil {
		t.Fatalf("Erreur lors de la création du client ServiceUsage: %v", err)
	}

	for _, apiName := range apis {
		fullResourceName := fmt.Sprintf("projects/%s/services/%s", projectID, apiName)
		resp, err := service.Services.Get(fullResourceName).Do()

		if err != nil {
			t.Errorf("Impossible de récupérer l'état de l'API %s: %v", apiName, err)
			continue
		}

		status := resp.State // "ENABLED" ou "DISABLED"
		if expectedEnabled {
			assert.Equal(t, "ENABLED", status, fmt.Sprintf("L'API %s devrait être activée", apiName))
		} else {
			// Note: Certaines APIs restent "ENABLED" par défaut sur GCP,
			// ce test vérifie si elle a bien été désactivée SI demandée.
			assert.Equal(t, "DISABLED", status, fmt.Sprintf("L'API %s devrait être désactivée", apiName))
		}
	}
}

func TestGoogleApiModule(t *testing.T) {
	t.Parallel()

	projectID := "qsw-terraform-lib-test"
	apisToTest := []string{
		"compute.googleapis.com",
		"dns.googleapis.com",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"project_id": projectID,
			"apis":       apisToTest,
		},
	})

	// 1. APRÈS LE DESTROY (via defer)
	// On vérifie que les APIs sont désactivées (ou dans l'état attendu) après le nettoyage
	defer func() {
		terraform.Destroy(t, terraformOptions)
		fmt.Println("🔍 Vérification post-destroy via SDK...")
		// On attend un peu que GCP propage l'état
		verifyApisStatus(t, projectID, apisToTest, false)
	}()

	// 2. APPLY
	terraform.InitAndApply(t, terraformOptions)

	// 3. APRÈS LE APPLY
	fmt.Println("🔍 Vérification post-apply via SDK...")
	verifyApisStatus(t, projectID, apisToTest, true)
}
