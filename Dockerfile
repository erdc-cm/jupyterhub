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

RUN pip install configparser
RUN	pip install ipyparallel==6.0.2 
RUN	pip install ipython==5.3.0
RUN	pip install terminado==0.6 
RUN	pip install jupyter==1.0.0 
RUN	pip install jupyterlab==0.18.1 
RUN	pip install ipywidgets==6.0.0 
RUN	pip install ipyleaflet==0.3.0 
RUN	pip install jupyter_dashboards==0.7.0 
RUN	pip install pythreejs==0.3.0 
RUN	pip install rise==4.0.0b1
RUN	pip install cesiumpy==0.3.3 
RUN	pip install bqplot==0.9.0 
RUN	pip install hide_code==0.4.0 
RUN	pip install matplotlib==2.0.2 
RUN	pip install ipympl
RUN	pip install ipymesh
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
RUN /usr/local/bin/jupyter dashboards quick-setup --sys-prefix
RUN /usr/local/bin/jupyter nbextension install --sys-prefix --py ipyparallel
RUN /usr/local/bin/jupyter nbextension enable --sys-prefix --py ipyparallel
RUN /usr/local/bin/jupyter serverextension enable --sys-prefix --py ipyparallel

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
