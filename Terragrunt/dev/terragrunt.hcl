include "root" {
  path = find_in_parent_folders()
}

# Surcharge et définition des variables spécifiques à l'environnement DEV
inputs = {
  # Compartiment OCI spécifique "Dev"
  compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaajac7psa2g36ski3niulrqevpuwhog7z53zywfefqtyzo26erk44q"
}
