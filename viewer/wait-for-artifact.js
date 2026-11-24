// Polls the Actions results service's ListArtifacts, the same listing
// actions/deploy-pages reads (through @actions/artifact). The service is
// internal to GitHub Actions, so this never fails the job: on an error or a
// timeout it warns and the deployment runs as it would without the wait.

const TIMEOUT_MS = 180_000;
const INTERVAL_MS = 2_000;
// Consecutive listings that must show the artifact, in case the listing is
// served by replicas that are not yet consistent
const REQUIRED_SIGHTINGS = 2;

module.exports = async ({ core, name }) => {
  const start = Date.now();
  const elapsed = () => ((Date.now() - start) / 1000).toFixed(1);
  try {
    const token = process.env.ACTIONS_RUNTIME_TOKEN;

    // The token's scp claim holds "Actions.Results:<run backend id>:<job backend id>"
    const claims = JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString());
    const scope = claims.scp.split(' ').find((s) => s.startsWith('Actions.Results:'));
    const [, runBackendId, jobBackendId] = scope.split(':');

    const url = new URL(
      '/twirp/github.actions.results.api.v1.ArtifactService/ListArtifacts',
      process.env.ACTIONS_RESULTS_URL,
    );
    const body = JSON.stringify({
      workflow_run_backend_id: runBackendId,
      workflow_job_run_backend_id: jobBackendId,
    });

    let sightings = 0;
    while (Date.now() - start < TIMEOUT_MS) {
      const res = await fetch(url, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body,
      });
      if (!res.ok) {
        throw new Error(`ListArtifacts returned HTTP ${res.status}`);
      }
      // The response omits the artifacts field when the list is empty
      const { artifacts = [] } = await res.json();
      sightings = artifacts.some((a) => a.name === name) ? sightings + 1 : 0;
      if (sightings >= REQUIRED_SIGHTINGS) {
        core.info(`Artifact "${name}" is listed after ${elapsed()}s`);
        return;
      }
      core.info(`${elapsed()}s: artifact "${name}" is ${sightings ? 'listed, confirming' : 'not listed yet'}`);
      await new Promise((resolve) => setTimeout(resolve, INTERVAL_MS));
    }
    core.warning(`Artifact "${name}" was not listed after ${elapsed()}s, deploying anyway`);
  } catch (e) {
    core.warning(`Could not check whether artifact "${name}" is listed (${e.message}), deploying anyway`);
  }
};
