# Build image witih: 
#   `docker build -t spf .`
# Afterwards run container with: 
#   `docker run -it spf /bin/bash`
# Run SPF with: 
#   `java -jar ../jpf-core/build/RunJPF.jar src/examples/XXX.jpf`
FROM adoptopenjdk/openjdk11:jdk-11.0.8_10-ubuntu
SHELL ["/bin/bash", "-c"]

# Switch from `sh -c` to `bash -c` as the shell behind a `RUN` command.
RUN apt update && apt-get upgrade -y
RUN apt-get update -y
RUN apt-get install -y build-essential
RUN apt-get install -y git
#RUN apt-get install -y ant
RUN apt install -y curl bash unzip zip -y

#install sdk manager
RUN curl -s "https://get.sdkman.io" | bash
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && sdk install gradle 7.2
ENV PATH=/root/.sdkman/candidates/gradle/current/bin:$PATH
# Download java 11(!) and jpf-core
RUN apt-get install -y  openjdk-11-jdk
RUN mkdir /usr/lib/JPF
WORKDIR /usr/lib/JPF
RUN git clone https://github.com/javapathfinder/jpf-core

# Setup jpf env
RUN mkdir /root/.jpf
RUN echo 'jpf-core = /usr/lib/JPF/jpf-core' >> /root/.jpf/site.properties
RUN echo 'extensions=${jpf-core}' >> /root/.jpf/site.properties

# Build jpf
WORKDIR /usr/lib/JPF/jpf-core
RUN git checkout master
#RUN cd jpf-core
RUN ./gradlew buildJars


# Setup path
ENV JPF_HOME=/usr/lib/JPF
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JPF_HOME/jpf-symbc/lib

