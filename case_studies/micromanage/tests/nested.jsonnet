{
    environments: {
        google: {
            kind: "Google",
            project: std.extVar("GCP_PROJECT"),
            region: "us-central1",
            serviceAccount: {
                client_email: std.extVar("GCP_EMAIL"),
                private_key: std.extVar("GCP_KEY"),
            },
            sshUser: std.extVar("USER"),
        },
    },

    local SingleInstance = {
        local service = self,

        kind: "Google",
        environment: "google",

        zone:: error "Must override zone.",
        image:: error "Must override zone.",
        machineType:: "g1-small",

        externalIp:: false,
        infrastructure: {
            google_compute_instance: {
                "${-}": {
                    name: "${-}",
                    machine_type: service.machineType,
                    zone: service.zone,
                    disk: [{
                        image: service.image,
                    }],
                    network_interface: {
                        network: "default",
                        access_config: 
                            if service.externalIp then [{}] else []
                    },
                    metadata: {
                    },
                    cmds: [],
                    bootCmds: [],
                }
            }
        },
        children: {},
        outputs: {
            [if service.externalIp then "address"]:
                "${google_compute_instance.${-}.network_interface.access_config.0.nat_ip}"
        },
    },

    instances: {
        kind: "Google",
        environment: "google",
        infrastructure: {},
        outputs: {},
        children: {
            wheezy: SingleInstance {
                image: "debian-7-wheezy-v20140814",
                zone: "us-central1-b",
            },
            ubuntu: SingleInstance {
                image: "ubuntu-1410-utopic-v20150625",
                zone: "us-central1-c",
            },
            "core-os": SingleInstance {
                image: "coreos-stable-717-3-0-v20150710",
                zone: "us-central1-f",
                externalIp: true,
            },
        }
    }
}
