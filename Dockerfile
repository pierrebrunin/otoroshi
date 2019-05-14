FROM openjdk:8-slim-stretch

RUN apt-get update  && \
    apt-get install -y --no-install-recommends curl && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get -y --no-install-recommends install yarn sbt nodejs&& \
    rm -rf /var/lib/apt/lists/*

# This command fails randomly with `gpg: keyserver receive failed: Cannot assign requested address`. Build again and pray :)

ENV PATH=/root/.cargo/bin:$PATH
