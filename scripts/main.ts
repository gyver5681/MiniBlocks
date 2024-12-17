import { BlockCustomComponent, world, system } from "@minecraft/server";

export const debuglog: boolean = false;

function getPreciseRotation(playerYRotation: number): number {
  // Transform player's head Y rotation to a positive
  if (playerYRotation < 0) playerYRotation += 360;
  // How many 16ths of 360 is the head rotation? - rounded
  const rotation = Math.round(playerYRotation / 22.5);

  // 0 and 16 represent duplicate rotations (0 degrees and 360 degrees), so 0 is returned if the value of `rotation` is 16
  return rotation !== 16 ? rotation : 0;
}

const HeadRotationBlockComponent: BlockCustomComponent = {
  beforeOnPlayerPlace(event) {
    const { player } = event;
    if (!player) return; // Exit if the player is undefined

    const blockFace = event.permutationToPlace.getState("minecraft:block_face");
    if (blockFace !== "up") return; // Exit if the block hasn't been placed on the top of another block

    // Get the rotation using the function from earlier
    const playerYRotation: number = player.getRotation().y;
    const rotation: number = getPreciseRotation(playerYRotation);

    // Tell Minecraft to place the correct `wiki:rotation` value
    event.permutationToPlace = event.permutationToPlace.withState("miniblocks:rotation", rotation);
  },
};

world.beforeEvents.worldInitialize.subscribe(({ blockComponentRegistry }) => {
  blockComponentRegistry.registerCustomComponent("miniblocks:head_rotation", HeadRotationBlockComponent);
});
