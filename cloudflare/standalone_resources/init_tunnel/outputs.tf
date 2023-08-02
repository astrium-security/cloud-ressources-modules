output "tunnel_id" {
  description = "L'ID du tunnel Cloudflare."
  value       = cloudflare_tunnel.tunnel.id
}

output "tunnel_name" {
  description = "Le nom du tunnel Cloudflare."
  value       = cloudflare_tunnel.tunnel.name
}

output "tunnel_secret" {
  description = "Le secret du tunnel Cloudflare."
  value       = cloudflare_tunnel.tunnel.secret
  sensitive   = true
}
