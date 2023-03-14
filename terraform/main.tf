
resource "digitalocean_tag" "jenkins" {
  name = "terraform:jenkins"
}

# Droplet
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-10-x64"
  name     = "${var.prefix}-hw-jenkins"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${var.do_ssh_fingerprint}"]
  tags     = ["${var.tag}"]

  connection {
    user        = "root"
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.do_private_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "install-jenkins.sh"
    destination = "/tmp/install-jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-jenkins.sh",
      "/tmp/install-jenkins.sh",
    ]
  }
}

# Firewall
resource "digitalocean_firewall" "jenkins" {
  name = "${var.prefix}-firewall-jenkins"

  droplet_ids = [digitalocean_droplet.jenkins.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8090"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
# Output IP address 
output "public_ip_server" {
  description = "Public IP of Digitalocean Droplet"
  value       = join("", ["http://", digitalocean_droplet.jenkins.ipv4_address, ":", "8080"])
}

