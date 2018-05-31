# Let's start by loading necessary packages
library(tidyverse)
library(quantmod)
library(data.table)
library(viridis)
library(htmlTable)
library(knitr)

# Load available data from the website on to the dataframe
my.names <- data.table(var=c("UNDCON1USA","UNDCON24USA","UNDCON5MUNSA","UNDCONTSA"),
                       name=c("1-unit","2-4 unit","5-unit","total"),
                       Description=c("1-Unit Structures",
                                     " 2-4 Unit Structures",
                                     "5-Unit Structures",
                                     "Total"),
                       Source=c("U.S. Bureau of the Census",
                                "U.S. Bureau of the Census",
                                "U.S. Bureau of the Census",
                                "U.S. Bureau of the Census"))


#Make a descriptive data table
htmlTable(my.names, caption="Data description")
df= getSymbols('UNDCON1USA',src='FRED', auto.assign=F) 

#Next, we slice off necessary data and assign to appropriate smaller dataframes
df = data.frame(date=time(df), coredata(df) )

df.24 =getSymbols('UNDCON24USA',src='FRED', auto.assign=F) 
df.24 = data.frame(date=time(df.24), coredata(df.24) )

df.5=getSymbols('UNDCON5MUNSA',src='FRED', auto.assign=F) 
df.5 = data.frame(date=time(df.5), coredata(df.5) )

df.all= getSymbols('UNDCONTSA',src='FRED', auto.assign=F) 
df.all = data.frame(date=time(df.all), coredata(df.all) )


#Merge and consolidate all data by "date" to graph them together in 1 graph
#Merge
df3<-merge(df,df.24,by="date")
df3<-merge(df3,df.5,by="date")
df3<-merge(df3,df.all,by="date")
dt<-data.table(df3)
# Consolidate the data 
dt %>% gather(var,value,-date) %>% data.table() ->dt2

# Merge on variable names
dt2<-merge(dt2,my.names,by="var")

#Transform data prior to plotting to make the data look 'normal'
dt2=dt2[,id:=1:.N, by=var]  # Index running from 1:N by group (var)
dt2=dt2[,var0:=100*value/sum(ifelse(id==1,value,0)),by=var] #create index 
 
# Create caption
mycaption<- "Source: U.S. Bureau of the Census. All are seasonally adjusted."

# Wrap caption 120 characters:
mycaption <- paste0(strwrap(mycaption, 120), sep="", collapse="\n")


# Create Plot
ggplot(data=dt2,aes(x=date,y=var0,color=name,linetype=name))+
  geom_line(size=1.1)+
  scale_y_log10(breaks=c(25,50,100,200,400))+
  theme_minimal()+theme(plot.caption=element_text(hjust=0),
                        legend.position="top")+
  guides(linetype=F)+
  scale_color_viridis(name="Variable",discrete=T,end=0.9)+
  labs(x="",y="Index, January 1970= 100 (log scale)",
       title=" US New Privately-Owned Housing Units Under Construction",
       caption=mycaption)



 
 
 
