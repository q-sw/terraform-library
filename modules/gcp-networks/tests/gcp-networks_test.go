package tests

import (
	"context"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"google.golang.org/api/compute/v1"
)

func TestNetworkModule(t *testing.T) {
	t.Parallel()

	projectID := "qsw-terraform-lib-test"
	region := "europe-west9" // Valeur par défaut de ton module [cite: 12]

	// Définition d'une topologie de test complexe
	networksInput := map[string]interface{}{
		"main-net": map[string]interface{}{
			"network": map[string]interface{}{
				"name":        "test-vpc-complex",
				"enable_ipv6": true, // Pour tester le support ULA
				"asn":         64512,
				"subnets": []map[string]interface{}{
					{
						"name":       "test-sub-v4",
						"cidr":       "10.0.1.0/24",
						"region":     region,
						"stack_type": "IPV4_ONLY",
					},
					{
						"name":       "test-sub-v6",
						"cidr":       "10.0.2.0/24",
						"region":     region,
						"stack_type": "IPV4_IPV6", // Test du dual-stack
					},
				},
				"firewall_rules": []map[string]interface{}{
					{
						"name":         "allow-http",
						"protocol":     "tcp",
						"ports":        []string{"80", "443"},
						"from_sources": []string{"0.0.0.0/0"},
					},
				},
			},
		},
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"project_id":     projectID,
			"default_region": region,
			"networks":       networksInput,
		},
	})

	// Nettoyage automatique
	defer terraform.Destroy(t, terraformOptions)

	// Déploiement
	terraform.InitAndApply(t, terraformOptions)

	// --- VÉRIFICATIONS VIA SDK ---
	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	assert.NoError(t, err)

	// 1. Vérification du VPC
	t.Run("VerifyVPC", func(t *testing.T) {
		vpc, err := computeService.Networks.Get(projectID, "test-vpc-complex").Do()
		assert.NoError(t, err)
		assert.True(t, vpc.EnableUlaInternalIpv6, "L'IPv6 ULA devrait être activé")
	})

	// 2. Vérification du Subnet Dual-Stack
	t.Run("VerifyDualStackSubnet", func(t *testing.T) {
		subnet, err := computeService.Subnetworks.Get(projectID, region, "test-sub-v6").Do()
		assert.NoError(t, err)
		assert.Equal(t, "IPV4_IPV6", subnet.StackType, "Le subnet devrait être en Dual-Stack")
		assert.Equal(t, "INTERNAL", subnet.Ipv6AccessType, "L'accès IPv6 devrait être INTERNAL")
	})

	// 3. Vérification de la règle Firewall
	t.Run("VerifyFirewall", func(t *testing.T) {
		fw, err := computeService.Firewalls.Get(projectID, "allow-http").Do()
		assert.NoError(t, err)
		assert.Equal(t, "tcp", fw.Allowed[0].IPProtocol)
		assert.Contains(t, fw.Allowed[0].Ports, "80")
	})
}
