variable network_name { default =  "netology-net" }
variable subnet_name { default =  "netology-subnet" }

variable image { default =  "ubuntu-2004-lts" }
variable name { default = "netology-vm"}

variable instance_count { default = 1 }
variable count_format { default = "%01d" } #server number format (-1, -2, etc.)
variable count_offset { default = 0 } #start numbering from X+1 (e.g. name-1 if '0', name-3 if '2', etc.)
variable platform_id { default = "standard-v1"}
variable description { default =  "instance from terraform" }
variable zone { default =  "" }
variable folder_id { default =  "" }

variable cores { default = "2"}
variable memory { default = "4"}
variable core_fraction { default = "20"}

variable boot_disk { default =  "network-hdd" }
variable disk_size { default =  "20" }

variable subnet_id { default = ""}
variable nat { default = "true"}
variable ipv6 { default = "false"}

variable users { default = "ubuntu"}


resource "yandex_vpc_network" "net" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = var.zone
}

data "yandex_compute_image" "image" {
  family = var.image
}

resource "yandex_compute_instance" "netology-vm" {
  count = var.instance_count
  name = "${var.name}-${format(var.count_format, var.count_offset+count.index+1)}"
  platform_id = var.platform_id
  hostname = "${var.name}-${format(var.count_format, var.count_offset+count.index+1)}"
  description = var.description
  zone = var.zone
  folder_id = var.folder_id

  resources {
    cores  = var.cores
    memory = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type = var.boot_disk
      size = var.disk_size
    }
  }
  network_interface {
    subnet_id = resource.yandex_vpc_subnet.subnet.id
    nat       = var.nat
    ipv6      = var.ipv6
  }

  metadata = {
    ssh-keys = "${var.users}:${file("~/.ssh/id_rsa.pub")}"
  }
}
