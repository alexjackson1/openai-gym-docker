ARG base_container=jupyter/tensorflow-notebook:latest
FROM $base_container

LABEL maintainer="Alex Jackson <alex.jackson@kcl.ac.uk>"

USER root

ARG gym_package="gym"
ARG gym_version="0.18.0"

RUN apt-get update && \
    apt-get -y install xvfb python3-opengl && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

ENV GYM_TARGET="${gym_package}=${gym_version}"

RUN mamba install --quiet --yes ${GYM_TARGET} && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN echo '#!/bin/bash' > /tmp/openai-gym.sh && \
    echo 'set -eux' >> /tmp/openai-gym.sh && \
    echo "Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &> xvfb.log &" >> /tmp/openai-gym.sh && \
    echo "export DISPLAY=:0" >> /tmp/openai-gym.sh && \
    echo 'start-notebook.sh --ServerApp.password=${JUPYTER_PASSWORD} --ServerApp.root_dir=/mnt/notebooks' >> /tmp/openai-gym.sh && \
    chmod +x /tmp/openai-gym.sh

CMD ["/tmp/openai-gym.sh"]
