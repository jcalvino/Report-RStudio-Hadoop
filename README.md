### Automatic report using __R language__ and database **Hadoop**
---

**ENVIRONMENT AND TOOLS:**
1. [Linux RedHat Enterprise 7](https://developers.redhat.com/products/rhel/download) 
1. [RSTUDIO Server Pro](https://rstudio.com/products/rstudio/download/)
1. [Hadoop](https://hadoop.apache.org/releases.html)

---

## ABOUT:

Criação de script R para ambiente linux e execução com compilador R Server. Script preparado para chamada em qualquer `gerenciamento de sistemas` como Tivoli Workload Scheduler utilizando passagem de paramentro `sysdate` ou equivalente.

---

## 1. Install R

Para instalar as dependências de tempo de execução necessárias para R, você precisará habilitar repositórios adicionais para pacotes de terceiros ou de origem usando os seguintes comandos:

**Habilite o repositório Extra Packages for Enterprise Linux (EPEL)**

$ sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

**No RHEL 7, ative o repositório opcional**

$ sudo subscription-manager repos --enable "rhel - * - optional-rpms"

**Se estiver executando o RHEL 7 em uma nuvem pública, como Amazon EC2, ative o repositório opcional do Red Hat Update Infrastructure (RHUI)**

$ sudo yum install yum-utils
$ sudo yum-config-manager --enable "rhel - * - optional-rpms"

$ export R_VERSION=3.6.3

**Download and install R**

$ curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm
$ sudo yum install R-${R_VERSION}-1-1.x86_64.rpm

**Para garantir que R esteja disponível na variável PATH do sistema padrão, crie links simbólicos para a versão de R que você instalou:**

$ sudo ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
$ sudo ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

---

## 2. Activation

$ sudo rstudio-server license-manager status
$ sudo rstudio-server license-manager activate <product-key>
$ sudo rstudio-server restart

## 3. Upload script R para o servidor Linux

Transferir arquivo **exec_extrac_report_git.r** para qualquer diretório no Linux. Ex.: (/home/prod/scripts/)

---

## CONFIGURANDO SHELL

## 1. Transferir arquivo para o servidor do Linux

copiar o shellScript rotina.sh para dentro de qualquer diretorio do Linux. Ex.: (/home/prod/procs/)

## 2. Configuração do arquivo rotina.sh

Configurar o path da chamada do script R para o caminho que você salvou no passo 3 da instalação do R, procurar o step01 no ShellScript e ajustar no exemplo abaixo:

---

de:

EXECUTANDO SCRIPT NO COMPILADOR DO R

/usr/bin/Rscript /home/user/exec_extrac_report_git.r $1 

para:

EXECUTANDO SCRIPT NO COMPILADOR DO R**

/usr/bin/Rscript /home/prod/scripts/exec_extrac_report_git.r $1 

--- 

## 3. Teste de execução

Realizar chamada de teste como no exemplo abaixo:

PARAMENTRO PASSADO DURANTE A CHAMADO DA ROTINA  EX: rotina.sh 20200701 (ano mes dia)

./home/prod/procs/rotina.sh 20201208
