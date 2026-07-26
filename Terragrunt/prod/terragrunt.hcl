include "root" {
  path = find_in_parent_folders()
}

# Surcharge et définition des variables spécifiques à l'environnement PROD
inputs = {
  # En temps normal on utiliserait un compartiment OCI spécifique "Prod"
  # Pour que ce code soit 100% fonctionnel, on utilise l'OCID de votre compartiment actuel
  compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaajac7psa2g36ski3niulrqevpuwhog7z53zywfefqtyzo26erk44q"
}
