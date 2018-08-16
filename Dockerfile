FROM rocker/tidyverse:3.5.1
MAINTAINER Andrew Heiss andrewheiss@gmail.com

# Install ed, since nloptr needs it to compile
# Install clang and ccache to speed up Stan installation
# Install libxt-dev for Cairo 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       ed \
       libnlopt-dev \
       gcc \
       clang \
       ccache \
       libxt-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

# Global configuration
# Use correct Stan Makevars: https://github.com/stan-dev/rstan/wiki/Installing-RStan-on-Mac-or-Linux#prerequisite--c-toolchain-and-configuration
# Last CXXFLAGS+= is an incantation I found somewhere that might speed stuff up?
RUN mkdir -p $HOME/.R/ \
    && echo "VER= \nCCACHE=/usr/bin/ccache \nCC=$(CCACHE) gcc$(VER) \nCXX=$(CCACHE) g++$(VER) \nCXX11=$(CCACHE) g++$(VER) \nCXX14=$(CCACHE) g++$(VER) \nCXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined \nCXXFLAGS+=-flto -Wno-unused-local-typedefs \nCXXFLAGS+=-Wno-ignored-attributes -Wno-deprecated-declarations \nCXXFLAGS+=-g -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -g -pedantic -g0 \n" >> $HOME/.R/Makevars

# Config for rstudio user
RUN mkdir -p $HOME/.R/ \
    && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined \nCXXFLAGS+=-flto -Wno-unused-local-typedefs \nCXXFLAGS+=-Wno-ignored-attributes -Wno-deprecated-declarations \n" >> $HOME/.R/Makevars \
    && echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
    && echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile \
    # Make R use ccache correctly: http://dirk.eddelbuettel.com/blog/2017/11/27/
    && echo "max_size = 5.0G\n# important for R CMD INSTALL *.tar.gz as tarballs are expanded freshly -> fresh ctime\nsloppiness = include_file_ctime\n# also important as the (temp.) directory name will differ\nhash_dir = false\n" \ >> $HOME/.ccache/ccache.conf

# Install Stan, rstanarm, and friends
RUN install2.r --error --deps TRUE \
        rstan loo bayesplot rstanarm rstantools shinystan brms ggmcmc \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install project-specific packages
# Also, reinstall ggplot2 using a more recent snapshot, since ggplot2 3.0 
# was released after the R 3.5.1 MRAN snapshot was generated
RUN install2.r --error --deps TRUE \
        Amelia countrycode cshapes DT future furrr ggstance here \
        huxtable imputeTS lme4 OECD pander stargazer validate WDI \
    && R -e "library(devtools); \
        install.packages('ggplot2', repos = 'https://mran.revolutionanalytics.com/snapshot/2018-07-27/'); \
        install_github('bbolker/broom.mixed'); \
        install_github('thomasp85/patchwork');" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install fonts
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
