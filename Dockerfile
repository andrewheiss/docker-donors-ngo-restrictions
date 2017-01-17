FROM andrewheiss/tidyverse-rstanarm
LABEL maintainer="Andrew Heiss <andrew@andrewheiss.com>"

# Install other important libraries
# Cairo needs libxt-dev first
RUN apt-get -y --no-install-recommends install \
    libxt-dev \
    && install2.r --error \
        Cairo pander countrycode WDI

# ---------------
# Install fonts
# ---------------
# Place to put fonts
RUN mkdir -p $HOME/fonts

# Source Sans Pro
COPY scripts/install_source_sans.sh /root/fonts/install_source_sans.sh
RUN . $HOME/fonts/install_source_sans.sh

# Open Sans
RUN mkdir -p /tmp/OpenSans
COPY scripts/install_open_sans.sh /root/fonts/install_open_sans.sh
COPY fonts/Open_Sans.zip /tmp/OpenSans/Open_Sans.zip
RUN . $HOME/fonts/install_open_sans.sh

# ---------------------------
# Get project code and data
# ---------------------------
RUN git clone https://github.com/andrewheiss/donors-ngo-restrictions.git
