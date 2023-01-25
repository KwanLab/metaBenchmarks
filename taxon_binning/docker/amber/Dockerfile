FROM condaforge/miniforge3:latest

COPY environment.yml ./environment.yml

RUN conda install --prune --name base mamba --yes
RUN mamba env update --name base --file=./environment.yml \
    && mamba clean --all --force-pkgs-dirs --yes

RUN git clone https://github.com/CAMI-challenge/AMBER

CMD [ "-h" ]
ENTRYPOINT [ "python", "AMBER/amber.py" ]