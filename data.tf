data "template_file" "docker_compose_config" {
  template = <<-TEMPLATE
    # Generated by terraform module. Do not edit manually!
    version: '3'

    services:
      instance:
        image: ${var.image}
        restart: always
        volumes:
          - './data:/home/parity/.local/share/io.parity.ethereum'
        ports:
          - '8545:8545'
          - '8546:8546'
          - '30303:30303'
          - '30303:30303/udp'
        command:
          - '--no-color'
          - '--no-download'
          - '--no-config'
          - '--db-compaction=ssd'
          - '--no-serve-light'
          - '--no-ipc'
          - '--no-secretstore'
          - '--interface=all'
          - '--nat=any'
          - '--allow-ips=all'
          - '--logging=${var.logging}'
          - '--network-id=${var.testnet ? 3 : 1}'
          - '--min-peers=${var.min_peers}'
          - '--max-peers=${var.max_peers}'
          - '--snapshot-peers=${var.snapshot_peers}'
          - '--max-pending-peers=${var.max_pending_peers}'
          - '--mode=${var.mode}'
          - '--mode-timeout=${var.mode_timeout}'
          - '--mode-alarm=${var.mode_alarm}'
          - '--tracing=${var.tracing}'
          - '--pruning=${var.pruning}'
          - '--pruning-history=${var.pruning_history}'
          - '--pruning-memory=${var.pruning_memory}'
          - '--cache-size-db=${var.cache_size_db}'
          - '--cache-size-blocks=${var.cache_size_blocks}'
          - '--cache-size-queue=${var.cache_size_queue}'
          - '--cache-size-state=${var.cache_size_state}'
          - '--cache-size=${var.cache_size}'
          - '--fat-db=${var.fat_db}'
%{ if var.whisper ~}
          - '--whisper'
          - '--whisper-pool-size=${var.whisper_pool_size}'
%{ endif ~}
          - '--jsonrpc-interface=all'
          - '--jsonrpc-hosts=all'
          - '--jsonrpc-cors=all'
          - '--jsonrpc-apis=${join(",", var.apis)}'
          - '--jsonrpc-threads=${var.jsonrpc_threads}'
          - '--ws-interface=all'
          - '--ws-hosts=all'
          - '--ws-apis=${join(",", var.apis)}'
          - '--ws-origins=${var.ws_origins}'
%{ if var.testnet ~}
          - '--chain=ropsten'
%{ endif ~}
%{ if length(var.extra_args) > 0 ~}
          ${indent(10, join("\n", formatlist("- '%s'", var.extra_args)))}
%{ endif ~}

%{ if var.ethereum_exporter ~}
      exporter:
        image: 4ops/ethereum-exporter:latest
        restart: always
        depends_on:
          - instance
        links:
          - 'instance:instance'
        ports:
          - '9144:9144'
        environment:
          ETHEREUM_API_URL: 'http://instance:8545'
          LOG_LEVEL: 'info'
%{ endif }
  TEMPLATE
}
