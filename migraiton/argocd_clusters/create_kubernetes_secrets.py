import chevron
import yaml


def load_kubeconfig(file_path):
    with open(file_path, "r") as file:
        data = yaml.safe_load(file)
    return data


def create_secret_yaml(kubeconfig_paths):
    for file_path in kubeconfig_paths:
        config = load_kubeconfig(file_path)
        ca_data = config["clusters"][0]["cluster"]["certificate-authority-data"]
        cert_data = config["users"][0]["user"]["client-certificate-data"]
        key_data = config["users"][0]["user"]["client-key-data"]
        cluster_name = config["clusters"][0]["name"]

        with open("template.yaml", "r") as f:
            args = {
                "CLUSTER_NAME": f'{cluster_name.replace("kind-", "")}-control-plane',
                "caData": ca_data,
                "certData": cert_data,
                "keyData": key_data,
            }

            r = chevron.render(f, args)
            with open(f"{cluster_name}-secrets.yaml", "w") as outfile:
                outfile.write(r)


if __name__ == "__main__":
    kubeconfig_paths = [
        "../terraform/cluster-a-config",
        "../terraform/cluster-b-config",
        "../terraform/cluster-c-config",
    ]
    create_secret_yaml(kubeconfig_paths)
