FROM ubuntu

RUN apt-get update \
	&& apt-get install -y \
	curl \
	git \
	nano \
	sudo \
	vim \
	wget \
	&& rm -rf /var/lib/apt/lists/*

ARG CODER_USER=coder
RUN useradd --groups sudo --no-create-home --shell /bin/bash ${USER} \
	&& echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
	&& chmod 0440 /etc/sudoers.d/${USER}
USER ${USER}
WORKDIR /home/${USER}

ARG CODER_AGENT_INIT_SCRIPT
ENTRYPOINT ["/bin/sh", "-c", "echo ${CODER_AGENT_INIT_SCRIPT} | base64 -d | sh"]