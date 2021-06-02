# Install dfctl and the binary into the Ubuntu container
# This image is from the original release of Ubuntu 18.04
# on April 26,2018. This is done with the intention of generating dependancy
# errors that are found in the runtime observability. 
FROM ubuntu:bionic-20180426 as target
# Download older packages by using sources.list with updated commented out
COPY sources.list /etc/apt/sources.list
# 
LABEL maintainer="john@deepfactor.io"
#
RUN apt-get update && apt-get install -y make openjdk-11-jdk-headless openssh-client vim maven
# added fix to get mvn to complie on original Ubuntu18.04 release
RUN /usr/bin/printf '\xfe\xed\xfe\xed\x00\x00\x00\x02\x00\x00\x00\x00\xe2\x68\x6e\x45\xfb\x43\xdf\xa4\xd9\x92\xdd\x41\xce\xb6\xb2\x1c\x63\x30\xd7\x92' > /etc/ssl/certs/java/cacerts && \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure
#
#RUN java --version
#RUN mvn --version
WORKDIR /app
COPY . /app
RUN ./mvnw clean package
ARG JAR_FILE=target/*.jar
RUN cp ${JAR_FILE} app.jar
ENTRYPOINT ["java", "-Dserver.port=80", "-jar", "app.jar"]




# # export APP_IMAGE=alpine-distro-3.9-or-greater:myapp
# # docker build -t ${APP_IMAGE}-df -f Dockerfile.alpine.df
# #   --build-arg "APP_IMAGE=${APP_IMAGE}" --build-arg "DF_APP_NAME=${DF_APP_NAME}" --build-arg "DF_COMPONENT=${DF_COMPONENT}"  .
# FROM alpine:3.11.5 as df-runtime
# RUN cd /etc/apk/keys && wget https://repo.deepfactor.io/repo/alpine/keys/dfbuild@deepfactor.io-5f35ef3a.rsa.pub
# RUN echo "https://repo.deepfactor.io/repo/alpine" >> /etc/apk/repositories
# RUN apk add deepfactor-runtime=1.3-r564
# ENV DF_RUN_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyaWQiOiJkYjY0NjZkMy02YzdiLTRlNWQtOGI1Yy0xZTUyZDlkOWJkOTgiLCJ0b2tlbmlkIjoiODEzYzgyNjItNTY5ZC00MDdjLTk1ZjAtYjBkMDYxMGZmN2I4Iiwic3ViZG9tYWluIjoiZGYiLCJjdXN0b21lcmlkIjoiMWY5NzYwZjUtYTNlMy00YjcyLWE4MmEtMTMwNTAxOTU5NWFjIiwidXNlcmxldmVsIjoiQ1VTVE9NRVIiLCJyb2xlaWQiOiI5ODVlNzc5Mi0wZWY4LTQwN2MtOTJkMi1lMWY5YzYwMjU2M2UiLCJyb2xlbmFtZSI6IkNfQURNSU4iLCJ0b2tlbl90eXBlIjoiREZfUlVOX1RPS0VOIiwiZXhwIjoxNjM5MjY2MTM1LCJpYXQiOjE2MDc3MzAxMzUsIm5iZiI6MTYwNzczMDEzNSwicG9ydGFsVVJMIjoiZGVlcGZhY3Rvci5mbGV4c2VydmVyLWRpdC5jb25uZWN0Y2RrLmNvbSIsImN1c3RvbWVyUG9ydGFsVVJMIjoiZGYuZGVlcGZhY3Rvci5mbGV4c2VydmVyLWRpdC5jb25uZWN0Y2RrLmNvbSIsInBvcnRhbENBIjoiTUlJRndEQ0NBNmlnQXdJQkFnSVVDWklVUGtPTzR1UEF0UFJDc0d1RElSOWY0Tjh3RFFZSktvWklodmNOQVFFTFxuQlFBd2FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2tOaGJHbG1iM0p1YVdFeEVUQVBCZ05WQkFjTVxuQ0ZOaGJpQktiM05sTVJNd0VRWURWUVFLREFwRVpXVndSbUZqZEc5eU1SMHdHd1lEVlFRRERCUkVaV1Z3Um1GalxuZEc5eUlGQnZjblJoYkNCRFFUQWVGdzB5TURFeU1URXhPVEF5TVRCYUZ3MHpNREV5TURreE9UQXlNVEJhTUdreFxuQ3pBSkJnTlZCQVlUQWxWVE1STXdFUVlEVlFRSURBcERZV3hwWm05eWJtbGhNUkV3RHdZRFZRUUhEQWhUWVc0Z1xuU205elpURVRNQkVHQTFVRUNnd0tSR1ZsY0VaaFkzUnZjakVkTUJzR0ExVUVBd3dVUkdWbGNFWmhZM1J2Y2lCUVxuYjNKMFlXd2dRMEV3Z2dJaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQ0R3QXdnZ0lLQW9JQ0FRRENPR004aXFzd1xuQmM0VkZPMVlkclFQNE94SXpOMXM0S0JKTDVwOFJjUS8rN3c2bWhvUHlwUXBTdWtJS1FGcDdYZDBnS0YzZjE3d1xuSlJhN0ZTRjBiekhMWUplUHlDUUR4MWI3WGhzWDJUVWJ1RWRYbDl1ZUExSGZyNTV3VjlvMndwZWExenRnUW9xTVxuTndKTFFvVmFYVlRXaUpndkt1TTFzamRZQlpMZWlnT3RjSE5mRDVsV1VMd3pxWEhCYkdWZUxKdldkN3JQMEcxUlxuZVFFKzd0WThoRmJaeHJKWnZoOWlRbkZvNFY1UFIyMHRJU0YxQUdFNFM2bXArV01aZzFTL2lQOEw5bFlONlZmWFxuYWtaaFJCZHR4RXd0d0V6Nk8wcXVYVUFpTzkzUTJxc1VXV1RLeE0rOTFlU2krSThPd3dnckdrUkUvc25IU3QxNFxuUTFmL0lvakw5L1Y2c3RPb0dnZnY3UUhxT2IxdE0wZjMrc2xoMERieVZnYUZVUCswOE40VGIycXljODlCNXVGNFxuUWt6WUZINEk0MmNSTS9XSDlieGtLbW9KNTFRV2Z5eVJ1RytuNzVFT3NnbFNZb0xGbFlxd3plQWhScFIyNHA0M1xuSXNXSmdSOU9SRVBZSjVlT08zdDZaTndJMDRuR3FwYkI4bWJPbW5iQUQ2bGl1czZsaG9UTXFmUXg2VkplbUxtMFxuUXdNYW9TQUpNVCtlWi9GUjFJNHQxd1RQUzlIelc2TXJmWTdFSFhKazJ5ZHFWRXVvdU0zZXE0dnJmZUVPbUhkSFxuNG1WYk9oaGVkb1dEWTI5VnlITm5QUkxlVHBIb2l3aXdBOEZZbGJiMS9MVkc5ME05bzJHV0VZSHpjTU1SZnZjVVxuajEwOExCNDk5Qk93UkpwR3o3V1MwaEd4MzM1S2tJOStxUUlEQVFBQm8yQXdYakFkQmdOVkhRNEVGZ1FVQ0xXdlxuc1NMVlBQbWFIT0FCWkpyQkZ4OVFndXN3SHdZRFZSMGpCQmd3Rm9BVUNMV3ZzU0xWUFBtYUhPQUJaSnJCRng5UVxuZ3Vzd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBTEJnTlZIUThFQkFNQ0FRWXdEUVlKS29aSWh2Y05BUUVMQlFBRFxuZ2dJQkFIbmdPb1l0RXhxdWQzcVNFcUdOM3ZEWWp1ZTJ4TFVkUjB3b1Z6N25OVHM0YTNVV2xRcy9vRkV1V21ic1xuaGpWamp0NndwOG9BSkpXUzM4R0pRZU9JOGFnMVhuWS8rT2FXRUNJZnAyTjFpTmpMNW8zS3NhdnBxN1o4NjAvcFxuMnhjVkM5TGJLZ21iSHVTQWN4ekVwanNtZWxkZFMzU0hUdTZadWdHU0FFVE9ZSlhtZ29QbGhrS3lsdzRXQU9ib1xuenc1MlpqU3ByZlJtSEE2dzlEdmVZR3FrZ2RvUVRMZmN4TjFlM3BvbkJBWGEraW1vanFxcTE5RWkwM0huclVSN1xuZEhUSjFHUWhkSXoxL3d1UnBrL09aMmFzUHhWcm42a2VXVWtDL2dLUTR0RGFMemhRY3NKeWY3Sy9RMGF1UHo5eVxuTEd4TVJOM052MXhXcVpVYjFNSEhqaGZocG9GeTA1L1pBR1ZObjFNL050ekI2M3B1R1lnM2NEV0t2MjdGbklqYVxubVZ2M3hvOGYxek1VQTZ5TFRHWVpKbGlFUkdWVUxYVER1eitSd2VDNGlpY2JHVEVXbXIwVzZYUURZQVlWTnYvY1xuODVVUklEUzd5MC9tQXlhSk1wejFZTVNFdjNvZWV0TDZkOXFIeGFjeW1qY1FsemhONnpYNUhqTC93czJrUTRHbVxuZkREZ2pGL0xIVXp6anpoenpDRkRRYjRyTDBoTE5Tb2JvTXkxNWFWMG1wa1RlZURHTXY1cjROSHVLZytzNWJzaVxuaUZ6UGc1WWhuNVNic2owSGFBeDlIbm9lS2dvRlJTOEdXZGNtaURPQi9zeU9LaExpdDVtNWtmSDNGcElnaXYxQVxuWlZ1ckNodjlNUEJGYkNwemxuU3BTdDB4VG1DSnV2Vk1RbXNmVzNJL0s0MjRjMzlmIn0.WYouSHprQ07M7kRNfNTf8cfwfFbXCJDhr_PXMHgk5RU
# # option: pass via build ARG or set here
# ENV DF_APP "keystone"
# ENV DF_COMPONENT "field-definitions-api"
# # If necessary, add --add-host=my-df-portal:10.0.0.1 to your image build AND run commands for DF portal DNS:
# RUN mkdir -p /opt/deepfactor/manifest
# RUN dfctl register -a "$DF_APP" -c "$DF_COMPONENT" -o /opt/deepfactor/manifest/df-manifest.json -v
# # option: dfctl register/create individual components in container
# # Warning: The above df-runtime container's built libdf.so install must match
# #  the version of the target container's libc.so.
# #  i.e. APP_IMAGE must contain a musl libc
# FROM sonar
# # Add runtime dependencies
# RUN IMG_USER=`id -u`
# USER root
# RUN apk add libstdc++ libexecinfo
# RUN mkdir -p /opt/deepfactor/manifest
# USER ${IMG_USER}
# COPY --from=df-runtime /usr/lib/libdf.so /usr/lib/libdf.so
# COPY --from=df-runtime /opt/deepfactor/manifest/df-manifest.json /opt/deepfactor/manifest/df-manifest.json
# # The following is an optional smoke test for redhat and debian distro types.
# RUN env LD_PRELOAD=/usr/lib/libdf.so DF_MANIFEST=/opt/deepfactor/manifest/df-manifest.json sh -c 'apk list > /dev/null' || \
#   (echo -e "\n\n\nError, DeepFactor dependency not met.\n\n\n/tmp/deepfactor.log:\n" \
#   && cat /tmp/deepfactor.log && false)
# COPY libdf.so /usr/lib/libdf.so
# # option: set LD_PRELOAD in app startup cmd or script
# ENV LD_PRELOAD=/usr/lib/libdf.so
# ENV DF_MANIFEST=/opt/deepfactor/manifest/df-manifest.json
