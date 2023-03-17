#importing the needed library
install.packages('tinytex')

library(tidyverse)
library(forcats)

#data()

View(msleep)

#?msleep

#STAGE 1: EXPLORING THE DATASET.  
#Checking the datatypes, number of observations & columns, NA, just understanding the data
#I am using one of the in-built datasets
#There are 83 observations and 11 variables
glimpse(msleep)
colnames(msleep)

#checking the unique values in the categorical variables
unique(msleep$vore)
unique(msleep$genus)
unique(msleep$order)
unique(msleep$conservation)


#STAGE 2: DATA CLEANING
#1. Removing NAs from categorical columns if no relationship with other columns is identified 
#    and fill the NAs in numeric variables with the minimums (or available fill policy)
#2. Changing datatypes if need be
#3. Check and remove duplicates


#get the minimum brainwt using base R
mean_brainwt <- mean(msleep$brainwt, na.rm = TRUE)
mean_brainwt

#change the vore variable datatype to factor (categorical) using base R
msleep$vore <- as.factor(msleep$vore)
class(msleep$vore)

#using tidyverse; select columns to work with
#Check for NAs, drop and fill in appropriately
#Remove duplicates using the distinct()
cleaned_data <- msleep %>% 
  select(name, genus,vore,order,sleep_total, sleep_cycle, awake, brainwt, bodywt) %>% 
  filter(!complete.cases(.)) %>% 
  drop_na(vore) %>% 
  mutate_at(c('sleep_total', 'sleep_cycle', 'awake'), ~replace_na(.,0)) %>% 
  mutate(brainwt = replace_na(brainwt, mean_brainwt)) %>%
  distinct()


cleaned_data


#STAGE 3: DATA WRANGLING/MANIPULATION; DESCRIBE AND SUMMARISE
#Creating additional columns if needed, filter, sort,re-coding categorical variables etc

cleaned_data %>% 
  arrange(desc(brainwt)) %>% 
  group_by(vore) %>% 
  summarise(min(bodywt), max(bodywt), mean(bodywt),
            min(brainwt), max(brainwt), mean(brainwt))

#creating a table (like a pivot table in excel)
cleaned_data %>% 
  select(vore, order) %>% 
  table()
  

#STAGE 4: VISUALIZATIONS
#Bar chart---best for single categorical variable; best for counts
#Histograms---Best for single numerical variable charts

theme_set(theme_minimal())

#Barplot (Frequency of the vore types)
cleaned_data %>% 
  ggplot(aes(x=vore))+
  geom_bar(fill="#97b3c6", show.legend = TRUE)+
  #theme_classic()+
  labs(x="Vore",
       y=NULL,
       title="Number of Observation per Vore Type")
         

###flip and sort bar charts (Horizontal Barplot)
cleaned_data %>% 
  ggplot(aes(x=fct_infreq(vore)))+
  geom_bar(fill="blue", show.legend = TRUE)+
  coord_flip()+
  #theme_classic()+
  labs(x="Vore",
       y=NULL,
       title="Number of Observation per Vore Type")


##plotting histogram for a single numeric variable
cleaned_data %>% 
  ggplot(aes(awake))+
  geom_histogram(binwidth = 2, fill="magenta")+
  theme_bw()+
  labs(x="Total Sleep",
       y=NULL,
       title="Histogram of Total Sleep")



##plotting Density for a single numeric variable
cleaned_data %>% 
  ggplot(aes(sleep_cycle))+
  geom_density()+
  theme_bw()+
  labs(x="Sleep Cycle",
       y=NULL,
       title="Density Plot of Sleep Cycle")


##creating a lollipop chart for a categorical and numeric variable
cleaned_data %>% 
  group_by(order) %>% 
  summarise(avg_sleep = mean(sleep_total)) %>% 
  mutate(order = fct_reorder(order,avg_sleep)) %>% 
  ggplot(aes(x = order, y = avg_sleep))+
  geom_point(size=3,colour="blue")+
  geom_segment(aes(x=order,
                   y=mean(cleaned_data$sleep_total),
                   xend = order,
                   yend=avg_sleep),
               colour="Orange")+
  geom_hline(yintercept = mean(cleaned_data$sleep_total),
             colour = "orange",
             linewidth = 1)+
  theme(axis.text.x = element_text(angle=90))+
  labs(title = "Average Sleep Time of Mammals by Order",
       x="",
       y="Hours")



#Scatter Plot Visualizations (best for visualizing 2 numeric variables)
cleaned_data %>% 
  ggplot(aes(x = bodywt,
             y = brainwt,
             color=vore))+
  geom_point(size=5, alpha=0.5)+
  geom_smooth()+
  coord_flip()+
  #facet_wrap(~vore)+
  labs(title = "Brain Weight Explained by Body Weight",
       x = "Body Weight",
       y = "Brain Weight")
