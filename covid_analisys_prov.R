library(rgdal)
library(raster)
library(mapview)
library(RColorBrewer)
library(geojsonio)
library(git2r)
library(rprojroot)
###############################################################################################################################################################################
setwd("/home/alf/Scrivania/lav_covid19")

############################################################################################################################################################################


prov_IT=readOGR(".","limiti_prov")
names(prov_IT@data)[3]="SIGLA"
prov_IT@data$SIGLA=as.character(prov_IT@data$SIGLA)
province_IT=readRDS("province_IT.rds")

covid_ita_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv")
covid_ita_reg_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-regioni/dpc-covid19-ita-regioni.csv")
covid_ita_pro_df=rio::import("https://github.com/pcm-dpc/COVID-19/raw/master/dati-province/dpc-covid19-ita-province.csv")
dates=as.Date(covid_ita_df$data)
datej=as.numeric(format(dates,"%j"))


covid_ita_pro_df$sigla_provincia[which(is.na(covid_ita_pro_df$sigla_provincia))]="NA"
province_IT$SIGLA=as.character(province_IT$SIGLA)


res=list()
for ( i in 1:length(province_IT$SIGLA))
{
temp_pro=covid_ita_pro_df[which(province_IT$SIGLA[i]==covid_ita_pro_df$sigla_provincia),]
temp_pro$totale_casi=as.numeric(temp_pro$totale_casi)

casi=tail(temp_pro$totale_casi,1)
nuovi_casi=tail(temp_pro$totale_casi,1)-tail(temp_pro$totale_casi,2)[1]
Cov19_Inc=(tail(temp_pro$totale_casi,1)/province_IT$Popolazione[i])*100
Delta_day=100*(tail(temp_pro$totale_casi,1)-tail(temp_pro$totale_casi,2)[1])/tail(temp_pro$totale_casi,1);

res[[i]]=data.frame(SIGLA=province_IT$SIGLA[i],casi,nuovi_casi,Cov19_Inc,Delta_day)

}

res_df=do.call("rbind",res)
province_IT@data=cbind(province_IT@data,res_df)
saveRDS(province_IT,"province_IT_last.rds")

mappe_light=province_IT
mappe_light@data=mappe_light@data[c(13:15,18:22)]
mappe_light@data[,7]=round(mappe_light@data[,7],2)
mappe_light@data[,8]=round(mappe_light@data[,8],2)
prov_IT@data=cbind(prov_IT@data,mappe_light@data[as.numeric(sapply(prov_IT@data$SIGLA,FUN=function(x) which(mappe_light@data$SIGLA %in% x  ==T))),])
prov_IT@data[,3]=NULL
writeOGR(prov_IT, ".", "mappe_light", driver="ESRI Shapefile",overwrite_layer = T)
prov_IT_json <- geojson_json(prov_IT)
geojson_write(prov_IT_json, file = "/home/alf/Scrivania/lav_covid19/web/covid_maps/data/mappe_light.geojson")

FileConnection <- file("GitHub.R")
writeLines( paste0("#This is a test script. Run at: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
            , FileConnection
)
close(FileConnection)

########################################################################################################################
# view with mapview
# pal <- colorRampPalette(brewer.pal(9, "Blues"))
# palred <- colorRampPalette(brewer.pal(9, "OrRd"))
# 
# m1=mapview::mapView(prov_IT,zcol="Cov19_Inc",col.regions=pal, map.types = c("OpenStreetMap"),alpha.regions = 0.6, legend = TRUE) + 
#   mapview::mapView(prov_IT,zcol="Delta_day",col.regions=palred,map.types = c("OpenStreetMap"),alpha.regions = 0.6, legend = TRUE)
# m1
########################################################################################################################




