#!/bin/bash

git -C $1 checkout --ours .
git -C $1 add .
git -C $1 commit -m "Resolve conflicts keeping ours"