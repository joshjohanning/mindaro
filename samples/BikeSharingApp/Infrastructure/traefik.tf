resource "azurerm_public_ip" "pip" {
  name                = "cdminPip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "cdminLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "kubernetes_namespace" "bikeappns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "traefik" {
  chart      = "traefik/traefik"
  name       = "traefik"
  namespace  = var.namespace
  repository = "https://helm.traefik.io/traefik"
  version    = "10.21.1"

  set {
    name  = "ingressClass.enabled"
    value = true
  }

  set {
    name  = "ingressClass.isDefaultClass"
    value = true
  }

  set {
    name  = "service.spec.loadBalancerIP"
    value = azurerm_public_ip.pip.ip_address
  }
}