package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"google.golang.org/api/compute/v1"
)

func TestPeeringModule(t *testing.T) {
	t.Parallel()

	projectID := "qsw-terraform-lib-test"
	localNetName := "vpc-a"
	peerNetName := "vpc-b"

	// Nom attendu généré par ton module
	expectedPeeringName := fmt.Sprintf("peering-%s-to-%s", localNetName, peerNetName)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixture",
		Vars: map[string]interface{}{
			"project_id": projectID,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// --- VALIDATION VIA SDK ---
	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	assert.NoError(t, err)

	// On récupère le réseau local pour inspecter ses peerings
	network, err := computeService.Networks.Get(projectID, localNetName).Do()
	assert.NoError(t, err)

	// Recherche du peering spécifique dans la liste
	var foundPeering *compute.NetworkPeering
	for _, p := range network.Peerings {
		if p.Name == expectedPeeringName {
			foundPeering = p
			break
		}
	}

	// Assertions
	assert.NotNil(t, foundPeering, "Le peering n'a pas été trouvé sur le réseau local")
	assert.Equal(t, "ACTIVE", foundPeering.State, "Le peering devrait être ACTIVE (réciprocité validée)")

	// Vérification des flags de routes [cite: 8, 15, 16]
	assert.True(t, foundPeering.ExportCustomRoutes, "L'export des routes personnalisées devrait être activé")
	assert.True(t, foundPeering.ImportCustomRoutes, "L'import des routes personnalisées devrait être activé")
}
