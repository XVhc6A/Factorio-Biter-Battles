from factoriotools/factorio:latest as serverbase


ENV PYTHONUNBUFFERED=1

RUN apk add --update --no-cache --no-progress openssh git python3 py3-pip \
   && ln -sf python3 /usr/bin/python
# run apt-get update \
#    && apt-get install -y curl git \
#    && rm -rf /var/lib/apt/lists/*
#    && bash ./update_testtorio.sh \

COPY . /opt/workdir/

RUN mkdir -p /opt/factorio/mods /factorio/scenarios /factorio/saves \
   && echo '{"mods": [{"name": "base","enabled": true}, {"name": "Testorio", "enabled": true}]}' > /opt/factorio/mods/mod-list.json \
   && cp /opt/workdir/tests/update_testtorio.sh /opt/factorio/mods \
   && cd /opt/factorio/mods \
   && ash ./update_testtorio.sh \
   && ls /opt/workdir \
   && cp -r /opt/workdir /factorio/scenarios/Factorio-Biter-Battles


# python3 /opt/workdir/tests/factorio_process_manager.py --factorio-exe /opt/factorio/bin/x64/factorio

#     - uses: addnab/docker-run-action@v3
#       with:
#         # TODO: Pin this
#         image: factoriotools/factorio:latest
#         options: -v /opt/factorio:/factorio --entrypoint "/scenario.sh" Factorio-Biter-Battles
