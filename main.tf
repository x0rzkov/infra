# BACKEND

terraform {
  backend "s3" {
    endpoint                    = "https://s3.fr-par.scw.cloud"
    region                      = "fr-par"
    bucket                      = "karolak-tfstate-bucket"
    key                         = "infra.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

# PROVIDERS

provider "scaleway" {}

provider "ovh" {}

# INSTANCES

module "app_instance" {
  source = "./modules/scw-instance"
  name   = "app"
  tags   = ["grocy", "nextcloud", "postgresql_server", "private", "redis", "rssbridge", "wallabag"]
}

module "lb_instance" {
  source  = "./modules/scw-instance"
  name    = "lb"
  type    = "START1-XS"
  tags    = ["public"]
  ipv4_id = module.lb_ip.id
}

module "smtp_instance" {
  source  = "./modules/scw-instance"
  name    = "smtp"
  type    = "START1-XS"
  tags    = ["imap", "postgresql_server", "public", "redis", "rspamd"]
  ipv4_id = module.mail_ip.id
}

module "web_instance" {
  source = "./modules/scw-instance"
  name   = "web"
  tags   = ["private"]
}

# IP

module "lb_ip" {
  source  = "./modules/scw-ip"
  name    = "lb"
  aliases = ["bag", "cloud", "git", "grocy", "mail", "ndata", "pfa", "rspamd", "rssbr", "www"]
}

module "mail_ip" {
  source  = "./modules/scw-ip"
  name    = "smtp"
  aliases = ["imap"]
}

# STORAGE

resource "scaleway_object_bucket" "nextcloud" {
  name = "karolak-nextcloud-data-bucket"
  acl  = "private"
}

resource "scaleway_object_bucket" "backup" {
  name = "karolak-backup-bucket"
  acl  = "private"
}

# DNS

resource "ovh_domain_zone_record" "apex" {
  zone      = "karolak.fr"
  fieldtype = "A"
  ttl       = "3600"
  target    = module.lb_instance.ipv4
}

resource "ovh_domain_zone_record" "autoconfig" {
  zone      = "karolak.fr"
  subdomain = "autoconfig"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "autoconfig.migadu.com."
}

resource "ovh_domain_zone_record" "autodiscover" {
  zone      = "karolak.fr"
  subdomain = "autodiscover"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "autodiscover.migadu.com."
}

resource "ovh_domain_zone_record" "blog" {
  zone      = "karolak.fr"
  subdomain = "blog"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "blog-nicolas-karolak.netlify.app."
}

resource "ovh_domain_zone_record" "caa_iodef" {
  zone      = "karolak.fr"
  fieldtype = "CAA"
  ttl       = "3600"
  target    = "0 iodef \"mailto:admin+caa@karolak.fr\""
}

resource "ovh_domain_zone_record" "caa_issue" {
  zone      = "karolak.fr"
  fieldtype = "CAA"
  ttl       = "3600"
  target    = "0 issue \"letsencrypt.org\""
}

resource "ovh_domain_zone_record" "crypto" {
  zone      = "karolak.fr"
  subdomain = "crypto"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "crypto-assr.netlify.app."
}

resource "ovh_domain_zone_record" "cv" {
  zone      = "karolak.fr"
  subdomain = "cv"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "cv-nicolas-karolak.netlify.app."
}

resource "ovh_domain_zone_record" "dkim" {
  zone      = "karolak.fr"
  subdomain = "mail._domainkey"
  fieldtype = "TXT"
  ttl       = "600"
  target    = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHNE49B2ZAJ7Qr3NSGXWeiAZKPJHkkJvXGlO94N+04Yz8RN5ScT7qPQrSiP/SwoisQ1HJ0D3gqwcS0mfmYLAevP9FFfzPURbdmyi9lHIW7uQSDdwzcRDLNl9kweU/aU7RHz7S85ebEP1Db/HgEuXhUPCaSzl5LOld6MFjzJ0Q+8QIDAQAB"
}

resource "ovh_domain_zone_record" "dkim_1" {
  zone      = "karolak.fr"
  subdomain = "key1._domainkey"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "key1.karolak.fr._domainkey.migadu.com."
}

resource "ovh_domain_zone_record" "dkim_2" {
  zone      = "karolak.fr"
  subdomain = "key2._domainkey"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "key2.karolak.fr._domainkey.migadu.com."
}

resource "ovh_domain_zone_record" "dkim_3" {
  zone      = "karolak.fr"
  subdomain = "key3._domainkey"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = "key3.karolak.fr._domainkey.migadu.com."
}

resource "ovh_domain_zone_record" "dmarc" {
  zone      = "karolak.fr"
  subdomain = "_dmarc"
  fieldtype = "TXT"
  ttl       = "600"
  target    = "v=DMARC1; p=none; ruf=mailto:postmaster+dmarc@karolak.fr; rua=mailto:re+zmzfjvcp9be@dmarc.postmarkapp.com;"
}

resource "ovh_domain_zone_record" "home" {
  zone      = "karolak.fr"
  subdomain = "home"
  fieldtype = "A"
  ttl       = "3600"
  target    = "109.15.68.39"
}

resource "ovh_domain_zone_record" "migadu" {
  zone      = "karolak.fr"
  fieldtype = "TXT"
  ttl       = "3600"
  target    = "hosted-email-verify=ggebx6zs"
}

resource "ovh_domain_zone_record" "mx" {
  zone      = "karolak.fr"
  fieldtype = "MX"
  ttl       = "3600"
  target    = "100 smtp.karolak.fr."
}

resource "ovh_domain_zone_record" "mx_10" {
  zone      = "karolak.fr"
  fieldtype = "MX"
  ttl       = "3600"
  target    = "10 aspmx1.migadu.com."
}

resource "ovh_domain_zone_record" "mx_20" {
  zone      = "karolak.fr"
  fieldtype = "MX"
  ttl       = "3600"
  target    = "20 aspmx1.migadu.com."
}

resource "ovh_domain_zone_record" "nas" {
  zone      = "karolak.fr"
  subdomain = "nas"
  fieldtype = "CNAME"
  ttl       = "3600"
  target    = ovh_domain_zone_record.home.subdomain
}

resource "ovh_domain_zone_record" "ns1" {
  zone      = "karolak.fr"
  fieldtype = "NS"
  ttl       = "3600"
  target    = "dns105.ovh.net."
}

resource "ovh_domain_zone_record" "ns2" {
  zone      = "karolak.fr"
  fieldtype = "NS"
  ttl       = "3600"
  target    = "ns105.ovh.net."
}

resource "ovh_domain_zone_record" "spf" {
  zone      = "karolak.fr"
  fieldtype = "TXT"
  ttl       = "600"
  target    = "v=spf1 include:spf.migadu.com mx a -all"
}

resource "ovh_domain_zone_record" "srv_imaps" {
  zone      = "karolak.fr"
  subdomain = "_imaps._tcp"
  fieldtype = "SRV"
  ttl       = 3600
  target    = "0 1 993 smtp.migadu.com."
}

resource "ovh_domain_zone_record" "srv_submission" {
  zone      = "karolak.fr"
  subdomain = "_submissions._tcp"
  fieldtype = "SRV"
  ttl       = 3600
  target    = "0 1 465 smtp.migadu.com."
}
