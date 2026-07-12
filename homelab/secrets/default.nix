{ inputs, ... }:
{
  age.secrets = {
    "restic/env".file = "${inputs.secrets}/restic/env.age";
    "restic/repo".file = "${inputs.secrets}/restic/repo.age";
    "restic/password".file = "${inputs.secrets}/restic/password.age";
  };

}
