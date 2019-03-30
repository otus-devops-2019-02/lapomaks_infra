# lapomaks_infra
lapomaks Infra repository

Для подключения к someinternalhost в одну команду с рабочего устройства можно использовать несколько способов: 
1. Так как из соображений безопасности на bastion не хранятся ssh-ключи для доступа к другим машинам внутри VPC, мы будем использовать SSH Agent Forwarding (ключ -A) чтобы использовать ключи, хранимые на локальной машине для аутентификации на someinternalhost (ключ -t для привязки консоли к stdin машины someinternalhost):
ssh -At 35.228.243.235 ssh 10.166.0.3
2. Использовать Jump Host
ssh -J 35.228.243.235 10.166.0.3

Для возможности использовать команды вида: ssh someinternalhost добавим настройки ProxyJump в конфигурационный файл ssh (общий /etc/ssh/ssh_config или пользовательский ~/.ssh/ssh_config)
Host someinternalhost
    HostName 10.166.0.3
    ProxyJump 35.228.243.235

Итоговая конфигурация:
Создано Virtual Private Cloud (VPC) в которую включены 2 машины bastion (внешний ip 35.228.243.235, внутрений 10.166.0.2) и someinternalhost (внутрений ip 10.166.0.3). Настроен и проверен доступ по ssh как к машине bastion, так и подключение к someinternalhost через bastion.
На машине bastion также установлен и настроен VPN-сервер Pritunl.

bastion_IP = 35.228.243.235
someinternalhost_IP = 10.166.0.3

Команда gcloud для создания и настройки инстанса с помощью скриптов (предполагается, что запускается из той же папки, где расположен startup_script): 
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server2 \
  --metadata-from-file startup-script=startup_script.sh \
  --restart-on-failure

Команда gcloud для создания правила firewall из консоли:
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --source-tags=reddit-app --source-ranges=0.0.0.0/0 --direction=INGRESS --priority=1000

testapp_IP = 35.228.159.70
testapp_port = 9292

