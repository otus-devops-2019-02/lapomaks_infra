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

При выполнении ДЗ по ansible сделано следующее:
1. На локальную машину установлен ansible
2. Часто используемые настройки вынесенны в файл ansible.cfg
3. Созданные раннее в GCP виртуальные машины описаны в файле Inventory в формате INI
4. Созданные раннее в GCP виртуальные машины описаны в файле Inventory в формате YAML
5. Написан playbook, который устанавливает приложение reddit на машину appserver

После удаления склонированного репозитория командой:
ansible app -m command -a 'rm -rf ~/reddit'
Следующее выполнение playbook из файла clone.yml привело к тому, что в состояние хоста были внесены изменения:
appserver                  : ok=2    changed=1    unreachable=0    failed=0

При выполнении второго ДЗ по ansible сделано следующее:
1. Создан playbook, в котором на хосты app и db происходит установка приложения reddit и БД MongoDb
2. Созданный на первом шаге playbook разбит на сценарии: "Configure MongoDB", "Configure App" и "Deploy App"
3. На основе сценариев из предыдущего шага созданы отдельные playbooks для развертывания Puma, MongoDb и деплоя приложения reddit
4. Создан основной сценарий site.yml из которого осуществляется вызов предыдущих сценариев
5. Изменен тип провижинга в packer шаблонах для создания образов reddit-app-base и reddit-db-base, теперь там используются сценарии ansible

ДЗ Ansible-3:
В процессе выполнения ДЗ выполнены следующие шаги:
1. Произведено разбиение playbooks на отдельные роли для конфигурирования хостов с приложением и БД
2. Созданы и параметризованы окружения для Stage и Prod
3. Для работы приложения использована community-роль jdauphant.nginx
4. Использованы возможности Ansible Vault: создан ключ и добавлены playbooks для создания пользователей приложения

ДЗ Ansible-4:
1. С помощью vagrant в Virtual Box созданы виртуальные машины dbserver и appserver
2. В скрипт vagrant добавлены provisioners для настройки созданных машин (установка и конфигурирование mongodb для dbserver, установка ruby, bundler, reddit для appserver)
3. С использованием Molecule описан хост для тестирования роли db и выполнены юнит-тесты, написанные с помощью TestInfra (написаны и выполнены тесты: БД выполняется, слушает порт 27017 и в конфиге БД указано 'bindIp: 0.0.0.0')
