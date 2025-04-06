FROM coredns/coredns:latest
EXPOSE 53/udp 53/tcp
ENTRYPOINT ["/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]