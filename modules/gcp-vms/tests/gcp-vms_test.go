package test

import (
	"context"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"google.golang.org/api/compute/v1"
)

func TestVMModule(t *testing.T) {
	t.Parallel()

	projectID := "qsw-terraform-lib-test"
	zone := "europe-west9-a"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixture",
		Vars: map[string]interface{}{
			"project_id": projectID,
		},
	})

	// Nettoyage automatique à la fin
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	assert.NoError(t, err)

	// --- TEST 1 : Logique de Forwarding (Tags) ---
	t.Run("ForwardingLogic", func(t *testing.T) {
		// On récupère la VM "router"
		router, err := computeService.Instances.Get(projectID, zone, "test-vm-router").Do()
		assert.NoError(t, err)
		// On récupère la VM "simple"
		simple, err := computeService.Instances.Get(projectID, zone, "test-vm-simple").Do()
		assert.NoError(t, err)

		// Vérification de la logique conditionnelle du tag "router"
		assert.True(t, router.CanIpForward, "Le tag 'router' doit activer le forwarding")
		assert.False(t, simple.CanIpForward, "Une VM sans tag 'router' doit avoir le forwarding à FALSE")
	})

	// --- TEST 2 : Multi-NIC et Dual-Stack ---
	t.Run("NetworkInterfaces", func(t *testing.T) {
		multi, err := computeService.Instances.Get(projectID, zone, "test-vm-multi").Do()
		assert.NoError(t, err)

		// Vérification du nombre d'interfaces
		assert.Equal(t, 2, len(multi.NetworkInterfaces), "La VM multi-nic doit avoir 2 interfaces")

		// Vérification de l'IPv6 Interne sur l'interface dual-stack [cite: 4, 15]
		assert.Equal(t, "IPV4_IPV6", multi.NetworkInterfaces[0].StackType)
		assert.Equal(t, "INTERNAL", multi.NetworkInterfaces[0].Ipv6AccessType)
	})

	// --- TEST 3 : Metadata et Disques ---
	t.Run("MetadataAndHardware", func(t *testing.T) {
		simple, err := computeService.Instances.Get(projectID, zone, "test-vm-simple").Do()
		assert.NoError(t, err)

		// Vérification de la taille du disque [cite: 2]
		assert.Equal(t, int64(10), simple.Disks[0].DiskSizeGb)

		// Vérification des metadata [cite: 9]
		foundEnv := false
		for _, item := range simple.Metadata.Items {
			if item.Key == "env" && *item.Value == "test" {
				foundEnv = true
			}
		}
		assert.True(t, foundEnv, "La metadata 'env: test' est manquante sur la VM simple")
	})
}
