# CRIANDO UM OUTPUT DE MENSAGEM COM DATA E HORA DO PROCESSAMENTO, ESSE COMANDO sys.time() PEGA OS DADOS DO SERVIDOR QUE ESTA INSTALADO A APLICAÇÃO DO R

cat(paste0(" ==========    EXECUTANDO  ->  exec_extrac_report_git.r - INICIO DO SCRIPT: ",Sys.time(),"   ========== \n\n"))

# RECEBE COMO ARGUMENTO AAAAMMDD PASSADOS NA EXECUCAO DO SHELLSCRIPT EX: 0101
argumentos <- commandArgs(TRUE)

# ALOCA A VARIAVEL PASSADA NA MEMORIA
args <- argumentos[1]

# DECLARA LIBRARY
library(data.table)
library(odbc)

#*********************INICIO*************************/
#*                AREA DE CONEXAO                   */
#****************************************************/
hive <- dbConnect(odbc::odbc(), 
                 Driver = "ARQUIVO.so", 
                 HOST = "IP", 
                 PORT = "PORTA", 
                 Username = "USER", 
                 Password = "SENHA")

#************** PROCESSAMENTO ***************

# BUSCA DADOS DA BASE DE INFORMAÇÃO DO HIVE E ALOCA NA MEMORIA
df <- dbGetQuery(hive,"SELECT campo01, campo02 
                         FROM LIB.TABELA;")

# TRATAMENTO DE CAMPO DA TABELA ALOCADA NA MEMORIA - PROGRAMAÇÃO EM R
df$campo01 <- as.numeric(df$campo01)
df$campo01 <-  gsub("[.]",",",df$campo01 )

df$campo02 <- as.Date(df$campo02)

        
# ************************************************************
# GERA ARQUIVO TXT SEPARANDO OS CAMPO POR ";"
# quote = F faz a gravação dos dados em string sem o "
# co.names = T MANTEM O NOME DAS COLUNAS NO ARQUIVO TXT
# ************************************************************
fwrite(df, file = "df.txt", sep = ";", quote = F, col.names = T)


# ----------------------------------------------------------------------------------
# EXTRACAO DE DADOS COM BASE DO ARQUIVO IMPORTADO E TRATADO
# ----------------------------------------------------------------------------------

# AJUSTE NOME DAS COLUNAS PARA TRATAMENTO
colunas <- data.frame(
  campos=c("DATAINICIAL","DATAFINAL","REGIAO","ESTADO","MUNICIPIO",
          "PRODUTO","NUMERODEPOSTOSPESQUISADOS","UNIDADEDEMEDIDA","PRECOMEDIOREVENDA","DESVIOPADRAOREVENDA",
          "PRECOMINIMOREVENDA","PRECOMAXIMOREVENDA","MARGEMMEDIAREVENDA","COEFDEVARIACAOREVENDA","PRECOMEDIODISTRIBUICAO",
          "DESVIOPADRAODISTRIBUICAO","PRECOMINIMODISTRIBUICAO","PRECOMAXIMODISTRIBUICAO","COEFDEVARIACAODISTRIBUICAO"),
  stringsAsFactors=F)

# LEITURA DO ARQUIVO CSV PARA A MEMORIA DO R
comb <- fread("SEMANAL_MUNICIPIOS-2019.csv",
                 col.names = colunas$campos)

# INICIO DO TRATAMENTO DOS CAMPOS PARA CALCULO

# CONVERTER CAMPO DE DATA - TROCAR SIMBOLO '/' POR '-' (PADRAO LEITURA DO R)
comb$DATAINICIAL <- gsub("/","-",comb$DATAINICIAL)
comb$DATAFINAL <- gsub("/","-",comb$DATAFINAL)


# CONVERTER CAMPO DE DATA - ESTRUTURAR O CAMPO PARA QUE TENHA O PADRAO DE DDMMYYYY PARA YYYYMMDD 
comb$DATAINICIAL <- dmy(comb$DATAINICIAL)
comb$DATAFINAL <- dmy(comb$DATAFINAL)

# FORMATCAO DE NUMERICO PARA CALCULO
comb$PRECOMEDIOREVENDA <-          gsub("-","0,000",comb$PRECOMEDIOREVENDA)
comb$DESVIOPADRAOREVENDA <-        gsub("-","0,000",comb$DESVIOPADRAOREVENDA)
comb$PRECOMINIMOREVENDA <-         gsub("-","0,000",comb$PRECOMINIMOREVENDA)
comb$PRECOMAXIMOREVENDA <-         gsub("-","0,000",comb$PRECOMAXIMOREVENDA)
comb$MARGEMMEDIAREVENDA <-         gsub("-","0,000",comb$MARGEMMEDIAREVENDA)
comb$COEFDEVARIACAOREVENDA <-      gsub("-","0,000",comb$COEFDEVARIACAOREVENDA)
comb$PRECOMEDIODISTRIBUICAO <-     gsub("-","0,000",comb$PRECOMEDIODISTRIBUICAO)
comb$DESVIOPADRAODISTRIBUICAO <-   gsub("-","0,000",comb$DESVIOPADRAODISTRIBUICAO)
comb$PRECOMINIMODISTRIBUICAO <-    gsub("-","0,000",comb$PRECOMINIMODISTRIBUICAO)
comb$PRECOMAXIMODISTRIBUICAO <-    gsub("-","0,000",comb$PRECOMAXIMODISTRIBUICAO)
comb$COEFDEVARIACAODISTRIBUICAO <- gsub("-","0,000",comb$COEFDEVARIACAODISTRIBUICAO)

comb$PRECOMEDIOREVENDA <- as.numeric(gsub(",",".",comb$PRECOMEDIOREVENDA))
comb$DESVIOPADRAOREVENDA <- as.numeric(gsub(",",".",comb$DESVIOPADRAOREVENDA))
comb$PRECOMINIMOREVENDA <- as.numeric(gsub(",",".",comb$PRECOMINIMOREVENDA))
comb$PRECOMAXIMOREVENDA <- as.numeric(gsub(",",".",comb$PRECOMAXIMOREVENDA))
comb$MARGEMMEDIAREVENDA <- as.numeric(gsub(",",".",comb$MARGEMMEDIAREVENDA))
comb$COEFDEVARIACAOREVENDA <- as.numeric(gsub(",",".",comb$COEFDEVARIACAOREVENDA))
comb$PRECOMEDIODISTRIBUICAO <- as.numeric(gsub(",",".",comb$PRECOMEDIODISTRIBUICAO))
comb$DESVIOPADRAODISTRIBUICAO <- as.numeric(gsub(",",".",comb$DESVIOPADRAODISTRIBUICAO))
comb$PRECOMINIMODISTRIBUICAO <- as.numeric(gsub(",",".",comb$PRECOMINIMODISTRIBUICAO))
comb$PRECOMAXIMODISTRIBUICAO <- as.numeric(gsub(",",".",comb$PRECOMAXIMODISTRIBUICAO))
comb$COEFDEVARIACAODISTRIBUICAO <- as.numeric(gsub(",",".",comb$COEFDEVARIACAODISTRIBUICAO))

comb$NUMERODEPOSTOSPESQUISADOS <- as.numeric(comb$NUMERODEPOSTOSPESQUISADOS)

# 1 - Estes valores estão distribuídos em dados semanais, agrupe eles por mês e calcule as médias de valores de cada combustível por cidade.

# TRATAMENTO ATRAVEZ DE LINGUAGEM R

valcomb <- comb %>%
          group_by(MES = substr(DATAFINAL,1,7), MUNICIPIO, PRODUTO) %>%
          summarise(MEDIA_PRECOMEDIOREVENDA = mean(PRECOMEDIOREVENDA))


# TRATAMENTO ATRAVEZ DE QUERY SQL (MESMO RESULTADO)

comb$anomes <- substr(comb$DATAFINAL,1,7)

valcomb <- sqldf("select anomes as mes,
                         MUNICIPIO,
                         PRODUTO,
                         avg(PRECOMEDIOREVENDA) as MEDIA_PRECOMEDIOREVENDA
                    from comb
                group by 1,2,3
                order by 1,2,3;")

# ************************************************************
# GERA ARQUIVO TXT SEPARANDO OS CAMPO POR ";"
# quote = F faz a gravação dos dados em string sem o "
# col.names = T MANTEM O NOME DAS COLUNAS NO ARQUIVO TXT
# row.names = F nao numera os registros gravados
# ************************************************************
fwrite(valcomb, "RESP_EX01.txt", sep = ";", row.names = F, col.names = T)


# 2 - Calcule a média de valor do combustível por estado e região.

# TRATAMENTO ATRAVEZ DE LINGUAGEM R

valcomb <- comb %>%
          group_by(ESTADO, REGIAO) %>%
          summarise(MEDIA_PRECOMEDIOREVENDA = mean(PRECOMEDIOREVENDA))

# TRATAMENTO ATRAVEZ DE QUERY SQL (MESMO RESULTADO)

valcomb <- sqldf("select ESTADO,
                         REGIAO,
                         avg(PRECOMEDIOREVENDA) as MEDIA_PRECOMEDIOREVENDA
                    from comb
                group by ESTADO,REGIAO
                order by ESTADO,REGIAO;")

# ************************************************************
# GERA ARQUIVO TXT SEPARANDO OS CAMPO POR ";"
# quote = F faz a gravação dos dados em string sem o "
# co.names = T MANTEM O NOME DAS COLUNAS NO ARQUIVO TXT
# row.names = F nao numera os registros gravados
# ************************************************************

fwrite(valcomb, "RESP_EX02.txt", sep = ";", row.names = F, col.names = T)


# 3 - Calcule a variância e a variação absoluta do máximo, mínimo de cada cidade, mês a mês

# TRATAMENTO ATRAVEZ DE LINGUAGEM R

valcomb <- comb %>%
          group_by(mes = substr(DATAFINAL,1,7), MUNICIPIO) %>%
          summarise(VARIANCIA_min = sqrt(var(PRECOMINIMOREVENDA,na.rm = T)),
                    VARIACAO_AB_min = sd(PRECOMINIMOREVENDA)*100/mean(PRECOMINIMOREVENDA),
                    VARIANCIA_max = sqrt(var(PRECOMAXIMOREVENDA,na.rm = T)),
                    VARIACAO_AB_max = sd(PRECOMAXIMOREVENDA)*100/mean(PRECOMAXIMOREVENDA))


# TRATAMENTO ATRAVEZ DE QUERY SQL

comb$anomes <- substr(comb$DATAFINAL,1,7)

valcomb <- sqldf("select anomes as mes,
                         MUNICIPIO,
                         sqrt(VARIANCE(PRECOMINIMOREVENDA)) as VARIANCIA_min,
                         (STDEV(PRECOMINIMOREVENDA)*100/avg(PRECOMINIMOREVENDA)) as VARIACAO_AB_min,
                         sqrt(VARIANCE(PRECOMAXIMOREVENDA)) as VARIANCIA_max,
                         (STDEV(PRECOMAXIMOREVENDA)*100/avg(PRECOMAXIMOREVENDA)) as VARIACAO_AB_max
                    from comb
                group by 1,2
                order by 1,2;")

# ************************************************************
# GERA ARQUIVO TXT SEPARANDO OS CAMPO POR ";"
# quote = F faz a gravação dos dados em string sem o "
# co.names = T MANTEM O NOME DAS COLUNAS NO ARQUIVO TXT
# row.names = F nao numera os registros gravados
# ************************************************************

fwrite(valcomb, "RESP_EX03.txt", sep = ";", row.names = F, col.names = T)

# 4 - Quais são as 5 cidades que possuem a maior diferença entre o combustível mais barato e o mais caro.

# TRATAMENTO ATRAVEZ DE LINGUAGEM R

valcomb <- comb %>%
          group_by(MUNICIPIO, PRODUTO) %>%
          summarise(VALOR_MAX = max(PRECOMAXIMOREVENDA))

valcomb2 <- valcomb %>%
          group_by(MUNICIPIO) %>%
          summarise(DIF_VALOR = max(VALOR_MAX) - min(VALOR_MAX))

valcomb2 <- valcomb2[order(valcomb2$DIF_VALOR, decreasing = T),]

valcomb2 <- valcomb2[1:5,]

fwrite(valcomb2, "/home/ibm9063/RESP_EX04.txt", sep = ";", row.names = F, col.names = T)

# TRATAMENTO ATRAVEZ DE QUERY SQL

valcomb <- sqldf("select MUNICIPIO, PRODUTO,
                         max(PRECOMAXIMOREVENDA) as VALOR_MAX
                    from comb
                group by 1,2
                order by 1,2;")

valcomb2 <- sqldf("select MUNICIPIO,
                          (max(VALOR_MAX) - min(VALOR_MAX)) as DIF_VALOR
                    from valcomb
                group by 1
                order by 2 desc
                  limit 5;")

# ************************************************************
# GERA ARQUIVO TXT SEPARANDO OS CAMPO POR ";"
# quote = F faz a gravação dos dados em string sem o "
# co.names = T MANTEM O NOME DAS COLUNAS NO ARQUIVO TXT
# row.names = F nao numera os registros gravados
# ************************************************************

fwrite(valcomb2, "RESP_EX04.txt", sep = ";", row.names = F, col.names = T)

# DISCONECTA DO BANCO DE DADOS E Remove as variaveis da memoria
dbDisconnect(hive)
rm(list = ls())
gc()
