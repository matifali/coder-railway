FROM codercom/enterprise-base:ubuntu

ARG CODER_AGENT_INIT_SCRIPT
ENTRYPOINT ["/bin/sh", "-c", "echo ${CODER_AGENT_INIT_SCRIPT} | base64 -d | sh"]