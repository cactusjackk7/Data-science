# R CODE FOR PREDICTING LOAN STATUS
#author: CACTUS JACK
#Date: 12/02/2021
#IMPORT NECESSARY LIBRARIES
library(readr)
library(tidyverse)
library(broom)
library(caret)

#IMPORTATION OF DATASET
df<-read_csv("loan_timing.csv",na="NA")
names(df)=c("origination","chargeoff")

#Partition dataset into two: default (charged off ) and current
index<-which(!(df$chargeoff=="NA"))
default<-df%>%slice(index)
current<-df%>%slice(-index)

# EXPLORATORY DATA ANALYSIS
#Figure 1: Histogram of days since origination for current loans
current%>%ggplot(aes(origination))+geom_histogram(color="white",fill="skyblue")+ xlab('days since origination')+ylab('count')+ ggtitle("Histogram of days since origination for current loans")+ theme(plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"),axis.title.x = element_text(color="black", size=12, face="bold"),axis.title.y = element_text(color="black", size=12, face="bold"),legend.title = element_blank())

#Figure 2: Histogram of days to charge-off for defaulted loans
default%>%ggplot(aes(chargeoff))+geom_histogram(color="white",fill="skyblue")+ xlab('days to charge-off')+ylab('count')+ ggtitle("Histogram of days to charge-off for defaulted loans")+ theme(plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"), axis.title.x = element_text(color="black", size=12, face="bold"), axis.title.y = element_text(color="black", size=12, face="bold"), legend.title = element_blank())

#Figure 3: Histogram of days since origination for defaulted loans
default%>%ggplot(aes(origination))+geom_histogram(color="white",fill="skyblue")+ xlab('days since origination')+ylab('count')+ ggtitle("Histogram of days since origination for defaulted loans")+ theme(plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"),axis.title.x = element_text(color="black", size=12, face="bold"),axis.title.y = element_text(color="black", size=12, face="bold"), legend.title = element_blank())

#Figure 4: Plot of days to charge-off vs. days since origination for defaulted loans
default%>%ggplot(aes(origination,chargeoff))+geom_point()+ xlab('days since origination')+ylab('days to charge-off')+ ggtitle("days to charge-off vs. days since origination")+ 
theme( plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"), axis.title.x = element_text(color="black", size=12, face="bold"), axis.title.y = element_text(color="black", size=12, face="bold"),legend.title = element_blank())

#Figure 5: Monte Carlo Simulation of Defaulted Loans
set.seed(2)
N <- 3*365 # loan duration in days
df_MC<
data.frame(u=round(runif(15500,0,N)),v=round(runif(15500,0,N)))
df_MC<-df_MC%>%filter(v<=u)
df_MC<-df_MC%>%filter(u<=730 & v<=730)#select loans within 1st 2 yrs
df_MC[1:nrow(default),]%>%ggplot(aes(u,v))+geom_point()+ xlab('days since origination')+ylab('days to charge-off')+ ggtitle("MC simulation of days to charge-off vs. days since origination")+ theme(plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"),axis.title.x = element_text(color="black", size=12, face="bold"),axis.title.y = element_text(color="black", size=12, face="bold"),legend.title = element_blank())

#Predicting fraction of these loans will have charged off by the time all of their 3-year terms are finished
set.seed(2)
B<-1000
fraction<-replicate(B, {
df2<-data.frame(u=round(runif(50000,0,N)),v=round(runif(50000,0,N))) df2<-df2%>%filter(v<=u) 
b2<-(df2%>%filter(u<=730 & v<=730))
total<-(nrow(df2)/nrow(b2))*nrow(default)
100.0*(total/50000.0)})

#Figure 6: Histogram for fraction of charged off loans after 3-year term using N = 1000 samples
fdf<-data.frame(fraction=fraction)
fdf%>%ggplot(aes(fraction))+geom_histogram(color="white",fill="skyblue")+ xlab('fraction of charged off loans after 3-year term')+ylab('count')+ ggtitle("Histogram of total fraction of charged off loans")+ 
theme( plot.title = element_text(color="black", size=12, hjust=0.5, face="bold"),axis.title.x = element_text(color="black", size=12, face="bold"),axis.title.y = element_text(color="black", size=12, face="bold"),legend.title = element_blank())

#Calculate Confidence Interval for Percentage of Defaulted Loans After 3-year Term
mean<-mean(fraction)
sd<-sd(fraction)
confidence_interval<-c(mean-2*sd, mean+2*sd)
