from factoriotools/factorio:latest as serverbase

COPY . /opt/workdir/

RUN apk add --update --no-cache --no-progress openssh git
# run apt-get update \
#    && apt-get install -y curl git \
#    && rm -rf /var/lib/apt/lists/*
#    && bash ./update_testtorio.sh \

RUN mkdir -p /opt/factorio/mods \
   && echo '{"mods": [{"name": "base","enabled": true}, {"name": "Testorio", "enabled": true}]}' >/opt/factorio/mods/mod-list.json \
   && cp /opt/workdir/tests/update_testtorio.sh /opt/factorio/mods \
   && cd /opt/factorio/mods \
   && ash ./update_testtorio.sh \
   && cd /opt/factorio \
   && ls \
   && pwd \
   && /opt/workdir \
   && mkdir -p scenarios \
   && cd /opt/factorio/scenarios \
   && cp -r /opt/workdir /opt/factorio/scenarios/Factorio-Biter-Battles

#     - uses: addnab/docker-run-action@v3
#       with:
#         # TODO: Pin this
#         image: factoriotools/factorio:latest
#         options: -v /opt/factorio:/factorio --entrypoint "/scenario.sh" Factorio-Biter-Battles
