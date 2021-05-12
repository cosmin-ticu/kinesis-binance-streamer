# load packages
library(data.table)
library(binancer)
library(rredis)

# establish connection with Redis
redisConnect()

# check all the keys in Redis
redisKeys('cosmo_symbol:*')

# get the keys and the corresponding values stored in Redis
symbols <- redisMGet(redisKeys('cosmo_symbol:*'))

# convert the list into a data table
symbols <- data.table(
  symbol = sub('^cosmo_symbol:', '', names(symbols)),
  N = as.numeric(symbols))
symbols

# extract the 'from' currency
symbols[, from := substr(symbol, 1, 3)]

# group by from and sum the quantities
symbols[, .(quantity = sum(N)), by = from]

# get the real-time prices in USD
prices <- binance_coins_prices()

# merge the two tables
dt <- merge(symbols, prices, by.x = 'from', by.y = 'symbol', all.x = TRUE, all.y = FALSE)

# calculate value in USD
dt[, value := as.numeric(N) * usd]

# calculate overall USD value of transactions
output <- dt[, sum(value)]

# calculate overall USD value of transactions by coin
dt[, sum(value), by = from]

# save the time in Eastern European Time
s <- Sys.time()
s <- .POSIXct(s, "EET")

# Print the message
print(paste0('The overall value of Binance transactions at ', s, 
             ' is: ',scales::dollar(output)))

# get time of stream start from Redis
start_time_daemon <- redisGet("time_of_start")

library(botor)
botor(region = 'eu-west-1')
token <- ssm_get_parameter('slack')

library(slackr)
slackr_setup(username = 'Cosmo Cosmo Cosmo', 
             bot_user_oauth_token = token, 
             icon_emoji = ':pepe_boom_box:')

# Start off by sending an informative slack message
slackr_msg(text = paste0('The overall value of Binance transactions between ', 
                         start_time_daemon, ' EET',' and ', s, ' EET',
                         ' is: ',scales::dollar(output)), 
           channel = '#bots-final-project')

library(ggplot2)
# create ggplot for outlying transactions
scatterplot_outliers <- ggplot(dt, aes(N, value)) +
  geom_point(aes(size = value, color = value)) +
  geom_label(aes(label = symbol), position = position_nudge(x = -300, y = 20000000)) +
  scale_y_continuous(labels = scales::dollar_format()) +
  scale_color_continuous(type = 'gradient') +
  theme_bw() +
  theme(legend.position = "none") +
  labs(x = "Number of transactions", y = "USD value of transactions",
       title = paste("Scatterplot of Binance transaction values betweem", start_time_daemon,
                     "and", s))
# create ggplot for coin transaction numbers
top5_to_plot <- dt[, .(quantity = sum(N)), by = from][order(quantity, decreasing = T)][1:5]
top5_binance_transactions <- ggplot(top5_to_plot, 
                                    aes(reorder(from, quantity), quantity)) +
  geom_col(aes(fill = quantity)) +
  scale_fill_continuous(type = 'gradient') +
  theme_bw() +
  labs(x = 'Binance Coin', y = 'Number of Transactions', 
       title = paste('Number of coin transactions between', start_time_daemon,
                     'and', s)) +
  theme(legend.position = "none")

# Send intermediary Slack messages describing ggplot
slackr_msg(text = "Let's drill-down on the number of pairwise transactions and see who's hot right now.", 
           channel = '#bots-final-project')

# send to slack
ggslackr(plot = scatterplot_outliers, channels = '#bots-final-project', width = 10, height = 8)
slackr_setup(username = 'Cosmo "The Millennial Crypto Lover" Cosmo', 
             bot_user_oauth_token = token, 
             icon_emoji = ':pepelove:')

# Send intermediary Slack messages describing ggplot
slackr_msg(text = "WOW! Sure looks like Bitcoin and Ethereum transactions to USD are hot right now.", 
           channel = '#bots-final-project')

slackr_setup(username = 'Cosmo Cosmo Cosmo', 
             bot_user_oauth_token = token, 
             icon_emoji = ':pepe_boom_box:')

# Send intermediary Slack messages describing ggplot
slackr_msg(text = "Now let's look at individual coins and rank them by transactions within the designated time period.", 
           channel = '#bots-final-project')

# send to slack
ggslackr(plot = top5_binance_transactions, channels = '#bots-final-project', width = 10, height = 8)
slackr_setup(username = 'Cosmo "The Binance" Cosmo', 
             bot_user_oauth_token = token, 
             icon_emoji = ':pepenerd:')

# Send goodbye Slack message
slackr_msg(text = "Dunno about you, but all this crypto talk on 10-minutes' worth of data got me ready to invest early retirement savings. 
           Giddy up, finance dweebs! See you on the flip side.", 
           channel = '#bots-final-project')
