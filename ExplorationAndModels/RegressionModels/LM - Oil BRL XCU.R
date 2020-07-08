#fit oil linear regression model with brlusd and copper as predictors 
library(Quandl)
library(dplyr)
library(reshape2)
library(lubridate)
library(tidyr)
library(ggplot2)
#montly diff
Quandl.api_key("")

startdate = "2015-09-01"
enddate = "2012-01-01"
wti = Quandl("CHRIS/CME_CL1", collapse = "week", start_date=startdate)
wti$diff = c(wti$Settle[1:(nrow(wti)-1)] - wti$Settle[2:nrow(wti)],0)
wti$group = "wti"
#wtim = wtim[2:nrow(wtim),]

brlusd = Quandl("CURRFX/BRLUSD", collapse = "week", start_date=startdate)
brlusd$diff = c(brlusd$Rate[1:(nrow(brlusd)-1)] - brlusd$Rate[2:nrow(brlusd)],0)
brlusd$group = "brlusd"

copper = Quandl("CHRIS/CME_HG1", collapse = "week", start_date=startdate)
copper$diff = c(copper$Settle[1:(nrow(copper)-1)] - copper$Settle[2:nrow(copper)],0)
copper$group = "copusd"
-#copm = copm[2:nrow(copm),]

bdi = Quandl("LLOYDS/BDI", collapse = "week", start_date=startdate)
bdi$diff = c(bdi$Index[1:(nrow(bdi)-1)] - bdi$Index[2:nrow(bdi)],0)
bdi$group = "bdi"
#brlm = brlm[2:nrow(brlm),]

# wti = filter(wti, wti$Date %in% bdi$Date) 

#copm = copm[2:nrow(copm),]
data1 = data.frame(oil = wti[,c("Settle")], brlusd = brlusd[,c("Rate")], copper = copper[,c("Settle")])
#Plot the data to look for multivariate outliers, non-linear relationships etc
plot(data1)
cor(data1)
#fit oil model with brlusd and copper as predictors (aka x-variable, explanatory variables)
oilmod = lm(oil ~ brlusd + copper, data = data1)
summary(oilmod)
oilbrl = lm(oil ~ brlusd, data = data1)
summary(oilbrl)
oilcop = lm(oil ~ copper, data = data1)
summary(oilcop)
#r^2 is 0.71 so around 70% of variation in the price of oil can be accounted for by brlusd and copper
#F-stat tests whether slope is zero 
# par(mfrow=c(2,2))
# plot(oilmod)
# par(mfrow=c(1,1))
oilcop = predict(oilcop)
gdata1 = melt(data.frame(data1$oil, wti$Date, oilcop),id="wti.Date")

oilbrl = predict(oilbrl)
gdata2 = melt(data.frame(data1$oil, wti$Date, oilbrl),id="wti.Date")

oilpred = predict(oilmod)
gdata3 = melt(data.frame(data1$oil, wti$Date, oilpred),id="wti.Date")

gdata = rbind(gdata1,gdata2,gdata3) 
ggplot(data=gdata,
       aes(x=wti.Date, y=value, colour=variable)) +
  geom_line(aes(linetype=variable)) +  
  geom_point()
# theme(panel.grid.minor = element_line(colour="blue", size=0.5)) + 
# scale_x_continuous(minor_breaks = seq(1, 10, 0.5))
# 
# oilres = resid(oilmod)
# plot(data1$oil, oilres)
# abline(0, 0)                  # the horizon
# abline(oilres)
# # oilrst = rstandard(oilmod)
# # plot(data1$oil,oilrst)
# qqnorm(oilrst)
# 
# cor(data1$copper, data1$brlusd, method="pearson")
# confint(oilmod, conf.level=0.95)