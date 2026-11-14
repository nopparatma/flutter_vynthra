// Resolves the version for this CI run from git tags.
//
//   rc/** : next patch on the major.minor line of BASE_VERSION (v1.1.3 -> 1.1.4,
//           or x.y.0 when the line has no tag yet). The tag itself is pushed by
//           the workflow after the build succeeds.
//   main  : never increments. Reuses the tag of the commit that was merged, so
//           prod ships exactly the version that was tested on rc.
//
// A commit that already has a tag (a re-run) reuses it on any branch.
// Inputs: BASE_VERSION, GITHUB_SHA, GITHUB_REF_NAME, GITHUB_RUN_NUMBER.
// Outputs (to GITHUB_OUTPUT): version, build, is_new.
import { execFileSync } from 'node:child_process';
import { appendFileSync } from 'node:fs';

const git = (...args) => execFileSync('git', args, { encoding: 'utf8' }).trim();
const fail = (message) => {
  console.log(`::error::${message}`);
  process.exit(1);
};

const { BASE_VERSION = '', GITHUB_SHA = '', GITHUB_REF_NAME = '', GITHUB_RUN_NUMBER = '', GITHUB_OUTPUT } = process.env;
const base = /^(\d+)\.(\d+)\.\d+$/.exec(BASE_VERSION);
if (!base) fail(`BASE_VERSION must look like 1.2.0, got "${BASE_VERSION}"`);
if (!/^[0-9a-f]{40}$/.test(GITHUB_SHA)) fail('GITHUB_SHA must be a full commit hash');
if (!/^\d+$/.test(GITHUB_RUN_NUMBER)) fail('GITHUB_RUN_NUMBER must be a number');
const line = `${base[1]}.${base[2]}`;
const isMain = GITHUB_REF_NAME === 'main';

// Tags of this line -> commit they point to (the peeled "^{}" entry for annotated tags).
const tags = new Map();
for (const row of git('ls-remote', '--tags', 'origin', `refs/tags/v${line}.*`).split('\n')) {
  const [sha, ref] = row.split('\t');
  const match = ref && /^refs\/tags\/(v\d+\.\d+\.(\d+))(\^\{\})?$/.exec(ref);
  if (!match) continue;
  const [, name, patch, peeled] = match;
  if (peeled || !tags.has(name)) tags.set(name, { sha, patch: Number(patch) });
}

// On main a merge commit carries the tested commit as its second parent.
const candidates = [GITHUB_SHA];
if (isMain) {
  try {
    candidates.push(git('rev-parse', '--verify', '-q', `${GITHUB_SHA}^2`));
  } catch {
    // not a merge commit
  }
}

const existing = [...tags.entries()]
  .filter(([, tag]) => candidates.includes(tag.sha))
  .sort((a, b) => b[1].patch - a[1].patch)[0];

let version;
let build = Number(GITHUB_RUN_NUMBER);
let isNew = false;

if (existing) {
  const [name] = existing;
  version = name.slice(1);
  // The tag message records the build number of the rc build ("build 42").
  git('fetch', '-q', '--no-tags', 'origin', `+refs/tags/${name}:refs/tags/${name}`);
  const recorded = /build (\d+)/.exec(git('for-each-ref', '--format=%(contents)', `refs/tags/${name}`));
  if (recorded) build = Number(recorded[1]);
} else if (isMain) {
  fail(`No v${line}.* tag on this commit. Only commits that passed CI on an rc branch can be released; wait for the rc run to finish, then merge that commit.`);
} else {
  const patches = [...tags.values()].map((tag) => tag.patch);
  version = `${line}.${patches.length ? Math.max(...patches) + 1 : 0}`;
  isNew = true;
}

console.log(`version=${version} build=${build} is_new=${isNew}`);
if (GITHUB_OUTPUT) appendFileSync(GITHUB_OUTPUT, `version=${version}\nbuild=${build}\nis_new=${isNew}\n`);
