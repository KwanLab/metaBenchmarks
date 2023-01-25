FROM condaforge/miniforge3:latest

COPY environment.yml ./environment.yml

RUN conda install --prune --name base mamba --yes
RUN mamba env update --name base --file=./environment.yml \
    && mamba clean --all --force-pkgs-dirs --yes

RUN git clone https://github.com/CAMI-challenge/OPAL

CMD [ "-h" ]
ENTRYPOINT [ "python", "OPAL/opal.py" ]