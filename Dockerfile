FROM erdc/debian_base:latest

MAINTAINER Proteus Project <proteus@googlegroups.com>

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV SHELL /bin/bash
ENV NB_USER jovyan
ENV NB_UID 1000
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create jovyan user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

RUN mkdir /home/$NB_USER/.jupyter && \
    mkdir /home/$NB_USER/.local && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

RUN chown -R $NB_USER:users /home/$NB_USER

RUN pip install -U pip
RUN pip install six configparser ipyparallel ipython terminado jupyter jupyterlab ipywidgets ipyleaflet pythreejs rise cesiumpy bqplot hide_code ipympl sympy transforms3d widgetsnbextension ipymesh
RUN /usr/local/bin/jupyter serverextension enable --py jupyterlab --sys-prefix
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix bqplot
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix pythreejs
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix ipympl
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix ipymesh
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix ipyleaflet
RUN /usr/local/bin/jupyter nbextension install --py --sys-prefix hide_code
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix hide_code
RUN /usr/local/bin/jupyter nbextension install --py --sys-prefix rise
RUN /usr/local/bin/jupyter nbextension enable --py --sys-prefix rise
RUN /usr/local/bin/jupyter nbextension install --sys-prefix --py ipyparallel
RUN /usr/local/bin/jupyter nbextension enable --sys-prefix --py ipyparallel
RUN /usr/local/bin/jupyter serverextension enable --sys-prefix --py ipyparallel

RUN REPO=http://cdn-fastly.deb.debian.org \
    && echo "deb $REPO/debian jessie main\ndeb $REPO/debian-security jessie/updates main" > /etc/apt/sources.list \
    && apt-get update && apt-get -yq dist-upgrade \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -yq --no-install-recommends --fix-missing nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN /usr/local/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager


EXPOSE 8888
WORKDIR /home/$NB_USER

ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start.sh /usr/local/bin/start.sh
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-notebook.sh /usr/local/bin/start-notebook.sh
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-singleuser.sh /usr/local/bin/start-singleuser.sh
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/jupyter_notebook_config.py /home/$NB_USER/.jupyter/jupyter_notebook_config.py

RUN chmod a+rx /usr/local/bin/*

RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER
