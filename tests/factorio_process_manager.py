#!/usr/bin/env python

import subprocess
from typing import List
import argparse
import time
import asyncio
import contextlib


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--factorio-exe", required=True, help="Factorio Executable")
    parser.add_argument("--factorio-args", default=[], nargs="+", help="Factorio executable args")
    # parser.add_argument("--optional2", help="optional argument 2", action="store_true")
    # parser.add_argument("-op3", "--optional3", action="store_true")
    return parser.parse_args()


class FactorioProcessManager:
    def __init__(self, factorio_exe: str, factorio_args: List[str]) -> None:
        self.factorio_exe = factorio_exe
        self.factorio_args = self.default_factorio_args() + factorio_args
        self.factorio_process = None
        self.timeout = 20.0
        self.logs = []

    def default_factorio_args(self) -> List[str]:
        return ["--start-server-load-scenario", "Factorio-Biter-Battles"]

    async def start(self):
        print(self.factorio_exe, self.factorio_args)
        self.factorio_process = await asyncio.create_subprocess_exec(
            self.factorio_exe, *self.factorio_args,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        self.logs = []

    async def is_running(self) -> bool:
        if self.factorio_process:
            with contextlib.suppress(asyncio.TimeoutError):
                await asyncio.wait_for(self.factorio_process.wait(), 1e-6)
            return self.factorio_process.returncode is None
        return False

    async def collect_logs(self):
        start = time.time()
        while self.factorio_process is not None and await self.is_running() and (time.time() - start) < self.timeout:
            if self.factorio_process.stdout is not None:
                print("running get lines")
                line = (await self.factorio_process.stdout.readline()).decode().rstrip("\n")
                print("got line", line)
                if line:
                    self.logs.append(line)
                    start = time.time()
                else:
                    time.sleep(0.25)
                    break

    async def end_game(self):
        if self.factorio_process:
            self.factorio_process.terminate()
            self.factorio_process = None

    def read_logs(self):
        print("LOGS START")
        for l in self.logs:
            print(l)
        print("LOGS END")

    async def _aio(self):
        await self.start()
        await self.collect_logs()
        await self.end_game()
        self.read_logs()

    def aio(self):
        asyncio.run(self._aio())


def main():
    args = parse_args()
    fpm = FactorioProcessManager(args.factorio_exe, args.factorio_args)
    fpm.aio()


if __name__ == "__main__":
    main()
