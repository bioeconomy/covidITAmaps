library(rgdal)
library(raster)
library(mapview)
library(RColorBrewer)
library(geojsonio)
library(git2r)

###############################################################################################################################################################################
setwd("")

###############################o#############################################################################################################################################
if(!dir.exists("covidITAmaps")) {clone(url="https://github.com/bioeconomy/covidITAmaps.git",local="covidITAmaps")}

repo <- init("covidITAmaps", bare=TRUE)
 map_cred=cred_user_pass(username = '', password = '')


############################################################################################################################################################################
prov_IT=geojson_read("gdam_ITA_2_cortesi.geojson",what="sp")
prov_IT@data$SIGLA=as.character(prov_IT@data$SIGLA)
province_IT_data=readRDS("province_IT_data.rds")

covid_ita_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv")
covid_ita_reg_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-regioni/dpc-covid19-ita-regioni.csv")
covid_ita_pro_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-province/dpc-covid19-ita-province.csv")
dates=as.Date(covid_ita_df$data)
datej=as.numeric(format(dates,"%j"))
covid_ita_pro_df$sigla_provincia[which(is.na(covid_ita_pro_df$sigla_provincia))]="NA"
province_IT_data$SIGLA=as.character(province_IT_data$SIGLA)


res=list()
for ( i in 1:length(province_IT_data$SIGLA))
{
temp_pro=covid_ita_pro_df[which(province_IT_data$SIGLA[i]==covid_ita_pro_df$sigla_provincia),]
temp_pro$totale_casi=as.numeric(temp_pro$totale_casi)

casi=tail(temp_pro$totale_casi,1)
nuovi_casi=tail(temp_pro$totale_casi,1)-tail(temp_pro$totale_casi,2)[1]
Cov19_Inc=(tail(temp_pro$totale_casi,1)/province_IT_data$Popolazione[i])*100
Delta_day=100*(tail(temp_pro$totale_casi,1)-tail(temp_pro$totale_casi,2)[1])/tail(temp_pro$totale_casi,1);

res[[i]]=data.frame(SIGLA=province_IT_data$SIGLA[i],casi,nuovi_casi,Cov19_Inc,Delta_day)

}

res_df=do.call("rbind",res)
res_df[,4]=round(res_df[,4],2)
res_df[,5]=round(res_df[,5],2)
pp=data.frame(SIGLA=prov_IT@data$SIGLA)

ids=as.numeric(sapply(prov_IT@data$SIGLA,FUN=function(x) which(province_IT_data$SIGLA %in% x  ==T)))
res_df$SIGLA=as.character(res_df$SIGLA)
merge_A=res_df[ids,]
merge_B=province_IT_data[ids,c("SIGLA","regioni","Popolazione","sup","dens")]

prov_IT@data=cbind(prov_IT@data,merge_B[,1:5],merge_A[,1:5])
prov_IT@data[,grep("SIGLA",names(prov_IT@data))[2:3]]=NULL
writeOGR(prov_IT, "mappe_light.geojson", layer=".", driver="GeoJSON")
writeOGR(prov_IT, ".", "mappe_light", driver="ESRI Shapefile",overwrite_layer = T)
mappe_light=readOGR(".", "mappe_light")
names(mappe_light@data)=c("prov_name", "prv_stt", "SIGLA", "reg_name", "prv_s_1", "regioni", "Popolazione", "sup", "dens", "casi", "nuovi_casi", "Cov19_Inc", "Delta_day")
geojson_write(mappe_light, file = "mappe_light.geojson")
#########################################################################################################

checkout(repo, "gh-pages") # checkout(repo, "gh-pages", create = TRUE)
status(repo)
file.copy("mappe_light.geojson","covidITAmaps/data/mappe_light.geojson",overwrite=T)
add(repo, "data/mappe_light.geojson") # adding all new or changed files
msg <- paste("update data file",Sys.time())
config(repo,user.name="Alf",user.email ="alfcrisci@gmail.com" )
commit(repo, msg)
push(repo, "origin", "refs/heads/gh-pages", credentials =map_cred)
status(repo)

#################################################################################################################################à

checkout(repo, "master")
status(repo)

#################################################################################################################################à
FileConnection <- file(paste0("covidITAmaps/logfile.md"))
writeLines( paste0("##This is a test script. \nRun at: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")), FileConnection)
close(FileConnection)
#################################################################################################################################à

add(repo, "logfile.md") # adding all new or changed files
msg <- paste("update logfile",Sys.time())
commit(repo, msg, session = TRUE)
push(repo, credentials =map_cred)
  
pull(repo)
#################################################################################################################################à
# commits(repo)
# branches(repo)
########################################################################################################################
# view with mapview
# pal <- colorRampPalette(brewer.pal(9, "Blues"))
# palred <- colorRampPalette(brewer.pal(9, "OrRd"))
# 
# m1=mapview::mapView(prov_IT,zcol="Cov19_Inc",col.regions=pal, map.types = c("OpenStreetMap"),alpha.regions = 0.6, legend = TRUE) + 
#   mapview::mapView(prov_IT,zcol="Delta_day",col.regions=palred,map.types = c("OpenStreetMap"),alpha.regions = 0.6, legend = TRUE)
# m1
########################################################################################################################

########################################################################################################################
# References
# [1] https://rpubs.com/chrimaho/GitHubAutomation


