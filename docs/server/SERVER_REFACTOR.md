# Server Refactoring Guide

## Overview

This document explains how to convert Cubyz into a dedicated server. The project already has a well-structured client-server architecture, making this transition relatively straightforward.

## Project Architecture

### Core Modules

1. **`src/main.zig`** - Application entry point
   - Initializes graphics, audio, network
   - Runs the game loop
   - Manages window and input

2. **`src/server/`** - Server logic (already exists!)
   - `server.zig` - Player connection management
   - `world.zig` - ServerWorld, world management
   - `terrain/` - World generation (biomes, caves, structures)
   - `command/` - Server console commands
   - `players.zig` - Player management
   - `permission.zig` - Permission system
   - `storage.zig` - World saving (region files)
   - `Entity.zig` - Server entities
   - `SimulationChunk.zig` - Chunk simulation
   - `BlockUpdateSystem.zig` - Block updates
   - `BlockDrop.zig` - Item drops

3. **`src/client/`** - Client logic
   - `Entity.zig` - Client entities
   - `entity_manager.zig` - Entity manager

4. **`src/network/`** - Network code
   - `protocols.zig` - Network protocols (handshake, chunks, entities, etc.)
   - `authentication.zig` - Player authentication

5. **`src/network.zig`** - Low-level networking (UDP sockets, STUN)

6. **`src/game.zig`** - Game logic (shared)

7. **Client-only modules** (to exclude from server):
   - `src/renderer/` - Rendering
   - `src/graphics/` - Graphics
   - `src/gui/` - User interface
   - `src/audio.zig` - Audio

## Operation Modes

In `src/server/world.zig`, there's a `Mode` enum:

```zig
pub const Mode = enum { singleplayer, multiplayer };
```

- **singleplayer** - Local server + client in one process
- **multiplayer** - Network server for multiplayer

## What's Already Available for Server

### Ready Components

1. **Full server code** in `src/server/`:
   - World generation (terrain/)
   - Physics and simulation
   - Server commands (/gamemode, /tp, /time, etc.)
   - Permission system
   - World save/load
   - Player management

2. **Network stack**:
   - UDP sockets
   - Synchronization protocols
   - Authentication
   - Data compression

3. **ServerWorld** (`src/server/world.zig`):
   - Chunk management
   - Block, item, biome palettes
   - Game time
   - Tick speed control

## Steps to Create Dedicated Server

### 1. Create Separate Entry Point

Create `src/server_main.zig`:

```zig
const std = @import("std");
const server = @import("server/server.zig");
const settings = @import("settings.zig");

pub fn main() void {
    // Initialize logging
    // Initialize network
    // Start server without client
    server.startFromExistingThread("world_name", null, .multiplayer);
    
    // Main server loop (command processing, ticks)
    while (true) {
        // Handle stdin commands
        // World tick
        // Save world
    }
}
```

### 2. Exclude Client Dependencies

What to remove from server build:
- **Graphics** (`src/renderer/`, `src/graphics/`)
- **Audio** (`src/audio.zig`)
- **GUI** (`src/gui/`)
- **Input handling** (keyboard, mouse)
- **Window manager** (`src/graphics/Window.zig`)

### 3. Modify `build.zig`

Add separate build target for server:

```zig
const server_exe = b.addExecutable(.{
    .name = "cubyz-server",
    .root_source_file = .{ .path = "src/server_main.zig" },
    .target = target,
    .optimize = optimize,
});
b.installArtifact(server_exe);
```

### 4. Key Code Changes

#### In `src/main.zig`:
- Separate initialization into server and client parts
- Remove OpenGL/Vulkan initialization for server
- Remove window creation

#### In `src/server/server.zig`:
- Function `startFromExistingThread` already exists (line 729)
- Accepts `mode: ServerWorld.Mode`
- Use `.multiplayer` for dedicated server

#### In `src/network/protocols.zig`:
- Protocols already split into `clientReceive` and `serverReceive`
- Server logic is independent from client

### 5. Server Configuration

Create `server_config.zon`:

```zig
.{
    .port = 25565,
    .maxPlayers = 20,
    .worldName = "my_world",
    .whitelistEnabled = false,
    .defaultGamemode = "survival",
    .allowCheats = false,
}
```

### 6. Dedicated Server Structure

Minimal server should:
1. Initialize network (`network.init()`)
2. Create world (`ServerWorld.init()`)
3. Start tick loop
4. Handle player connections
5. Process console commands
6. Periodically save world

## Useful Files to Study

1. **`src/server/server.zig`** (line 729) - `startFromExistingThread()`
2. **`src/server/world.zig`** (line 476) - `Mode` enum
3. **`src/network/protocols.zig`** - All network protocols
4. **`src/server/command/`** - Example server commands
5. **`src/server/stdin_handler.zig`** - Console input handling

## Potential Issues

1. **Global variable dependencies**: Some modules may reference `main.game.world` instead of `main.server.world`

2. **Graphics initialization**: Ensure server doesn't try to initialize OpenGL/Vulkan

3. **Threads**: Server may use same threads as client - may need separation

4. **Assets**: Server only needs server assets (audio can be disabled)

## Recommendations

1. Start by creating minimal `server_main.zig`
2. Gradually remove client dependencies
3. Test build at each step
4. Use `@import("builtin")` to check target platform
5. Add logging for debugging
