FROM mcr.microsoft.com/mssql/server:2019-latest

ARG sapw

USER root
RUN mkdir data

# Include schema and initial data
COPY ./LeafDB.sql ./LeafDB.Data.sql ./LeafDB.Exec.sql ./SynPuf_OMOP.Restore.sql ./SynPuf_OMOP.Shrink.sql ./
COPY ./SynPuf_OMOP.bak ./data/

# Accept EULA
ENV ACCEPT_EULA Y

# Volumize somewhere to interact with host if needed
#VOLUME /bak

# Set up database
#RUN /opt/mssql/bin/sqlservr & sleep 10 \
#    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} -i ./LeafDB.sql \
#    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} -i ./LeafDB.Data.sql \
#    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} -i ./LeafDB.Exec.sql \
#    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} -i ./SynPuf_OMOP.Restore.sql \
#    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} -i ./SynPuf_OMOP.Shrink.sql \
#    && pkill sqlservr
#
#RUN rm /data/SynPuf_OMOP.bak
