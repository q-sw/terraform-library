{
  description = "Environnement de développement pour tester le module Terraform GCP Services";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Requis pour certains composants du SDK Google
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Infrastructure as Code
            terraform
            tflint
            checkov

            # Go (pour Terratest)
            go
            gotools
            golangci-lint

            # Google Cloud SDK
            google-cloud-sdk
          ];

          shellHook = ''
            echo "--- 🛠️ Terraform & Terratest Dev Environment ---"
            echo "Terraform: $(terraform --version | head -n 1)"
            echo "Go: $(go version)"
            echo "GCP SDK: $(gcloud --version | head -n 1)"
            echo "------------------------------------------------"

            # Astuce : définit le dossier de cache pour les plugins Terraform
            export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            mkdir -p "$TF_PLUGIN_CACHE_DIR"

             echo "--- 🛠️ Configuration automatique du module Go ---"

             # On se déplace dans le dossier des tests s'il existe
             if [ -d "tests" ]; then
               cd tests

               # Si go.mod n'existe pas ou est corrompu, on le réinitialise
               if [ ! -f "go.mod" ]; then
                 echo "📦 Initialisation du module Go..."
                 go mod init github.com/q-sw/terraform-lib/gcp-apis
               fi

               # On force la résolution propre de Terratest pour éviter l'ambiguïté
               echo "🔍 Nettoyage et synchronisation des dépendances..."
               go get github.com/gruntwork-io/terratest@latest
               go mod tidy

               cd ..
             fi

             echo "------------------------------------------------"
          '';
        };
      });
}

