#master file
setwd("./GTAP_K_R")
#execution
source("Agg/IOT/Dataload.r")#load IO (csv=> rdata)
source("Agg/IOT/IOimport.r")#Add names/construct scrap in  scrap out 
source("Energy_Estimation/EnergyIO.r")# Energy IO
source("Emissions_Estimation/GHG_fuel.r") #GHG IO: fuel use
source("Emissions_Estimation/GHG_proc.r") #GHG IO: process 

#Write GHG_IO, Energy_IO
t=2010

write.csv(Emit_Dir0, file=paste(paste("GIO",t,sep="_"),"csv",sep="."))
write.csv(Emit_Dir0_FinD, file=paste(paste("GIO_FD",t,sep="_"),"csv",sep="."))
write.csv(Emit_Prcs,file=paste(paste("GHG_p",t,sep="_"),"csv",sep="."))
write.csv(IOT_energy,file=paste(paste("EIO",t,sep="_"),"csv",sep="."))
IOT_E_FinD=Emit_Dir0_FinD
IOT_E_FinD[,]=0
IOT_E_FinD[,1]=IOT_energy_FinD[,1]
IOT_E_FinD[,(2:(dim(IOT_E_FinD)[2]-1))]=IOT_energy_FinD[,(2:(dim(IOT_E_FinD)[2]-1))]
IOT_E_FinD[,(dim(IOT_E_FinD)[2])]=IOT_energy_FinD[,(dim(IOT_E_FinD)[2])]

write.csv(IOT_E_FinD,file=paste(paste("EIO_FD",t,sep="_"),"csv",sep="."))
setwd("../")