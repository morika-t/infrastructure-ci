FROM relintdockerhubpushbot/cf-deployment-concourse-tasks
MAINTAINER https://github.com/cloudfoundry/infrastructure-ci

# Install go
RUN wget https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.7.3.linux-amd64.tar.gz && \
  rm -rf go1.7.3.linux-amd64.tar.gz

# Create directory for GOPATH
RUN mkdir -p /go/bin

# set GOPATH
ENV GOPATH /go

# add go and GOPATH/bin to PATH
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# go install latest bosh-bootloader develop
RUN git clone https://github.com/cloudfoundry/bosh-bootloader /go/src/github.com/cloudfoundry/bosh-bootloader && \
  cd /go/src/github.com/cloudfoundry/bosh-bootloader > /dev/null && \
  git checkout develop && \
  git submodule update --init --recursive && \
  go install github.com/cloudfoundry/bosh-bootloader/bbl
