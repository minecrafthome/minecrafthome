int nextInt(ulong* seed, short bound);
int next(ulong* seed, short bits);
int nextIntUnknown(ulong* seed, short bound);
unsigned char extract(const unsigned int heightMap[], int id);
void increase(unsigned int heightMap[], int id, int val);

#define WANTED_CACTUS_HEIGHT 20
#define FLOOR_LEVEL 63

kernel void crack(global int *data, global ulong* answer)
{
    int id = get_global_id(0);
    ulong originalSeed = (((ulong)data[0] * (ulong)data[1] + (ulong)id) << 4) | data[8];
    ulong seed = originalSeed;

    short position = -1;
    short currentHighestPos = 0, posMap;
    short posX, posY, posZ;
    short initialPosX, initialPosY, initialPosZ, initialPos;

    uint heightMap[205];

    for (short i = 0; i < 205; i++) {
        heightMap[i] = 0;
    }

    for (short i = 0; i < 10; i++) {
        if (WANTED_CACTUS_HEIGHT - extract(heightMap, currentHighestPos) > 9 * (10 - i)) {
            return;
        }

        initialPosX = next(&seed, 4) + 8;
        initialPosZ = next(&seed, 4) + 8;
        initialPos = initialPosX + initialPosZ * 32;

        if (position == -1) {
            if (initialPos == data[3]) {
                position = 0;
            } else if (initialPos == data[4]) {
                position = 1;
            } else if (initialPos == data[5]) {
                position = 2;
            }

            if (position != -1) {
                int bit = (int)((originalSeed >> 4) & 1);

                if (data[6] != position) {
                    if (bit == data[9]) return;
                } else {
                    if (bit != data[9]) return;
                }

                increase(heightMap, initialPos, data[7]);

                if (extract(heightMap, currentHighestPos) < extract(heightMap, initialPos)) {
                    currentHighestPos = initialPos;
                }
            }
        }

        short terrainHeight = (extract(heightMap, initialPos) + FLOOR_LEVEL + 1) * 2;
        initialPosY = nextIntUnknown(&seed, terrainHeight);

        for (short a = 0; a < 10; a++) {
            posX = initialPosX + next(&seed, 3) - next(&seed, 3);
            posY = initialPosY + next(&seed, 2) - next(&seed, 2);
            posZ = initialPosZ + next(&seed, 3) - next(&seed, 3);
            posMap = posX + posZ * 32;

            if (position == -1) {
                if (posMap == data[3]) {
                    position = 0;
                } else if (posMap == data[4]) {
                    position = 1;
                } else if (posMap == data[5]) {
                    position = 2;
                }

                if (position != -1) {
                    int bit = (int)((originalSeed >> 4) & 1);

                    if (data[6] != position) {
                        if (bit == data[9]) return;
                    } else {
                        if (bit != data[9]) return;
                    }

                    increase(heightMap, posMap, data[7]);

                    if (extract(heightMap, currentHighestPos) < extract(heightMap, posMap)) {
                        currentHighestPos = posMap;
                   }
                }
            }

            if (posY <= extract(heightMap, posMap) + FLOOR_LEVEL) continue;

            short offset = 1 + nextIntUnknown(&seed, nextInt(&seed, 3) + 1);

            for (short j = 0; j < offset; j++) {
                if ((posY + j - 1) > extract(heightMap, posX + posZ * 32) + FLOOR_LEVEL || posY < 0) continue;
                if ((posY + j) <= extract(heightMap, (posX + 1) + posZ * 32) + FLOOR_LEVEL) continue;
                if ((posY + j) <= extract(heightMap, (posX - 1) + posZ * 32) + FLOOR_LEVEL) continue;
                if ((posY + j) <= extract(heightMap, posX + (posZ + 1) * 32) + FLOOR_LEVEL) continue;
                if ((posY + j) <= extract(heightMap, posX + (posZ - 1) * 32) + FLOOR_LEVEL) continue;

                increase(heightMap, posMap, 1);

                if (extract(heightMap, currentHighestPos) < extract(heightMap, posMap)) {
                    currentHighestPos = posMap;
                }
            }
        }

    }
    if (extract(heightMap, currentHighestPos) >= WANTED_CACTUS_HEIGHT) {
        answer[atomic_add(&data[2], 1)] =
        		((ulong)extract(heightMap, currentHighestPos)) << 58UL |
        		(((ulong)data[position + 3]) << 48UL) |
        		originalSeed;
    }
}

int next(ulong* seed, short bits)
{
    *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
    return *seed >> (48 - bits);
}

int nextInt(ulong* seed, short bound)
{
    int bits, value;
    do {
        *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
        bits = *seed >> 17;
        value = bits % bound;
    } while(bits - value + (bound - 1) < 0);
    return value;
}

int nextIntUnknown(ulong* seed, short bound)
{
    if((bound & -bound) == bound) {
        *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
        return (int)((bound * (*seed >> 17)) >> 31);
    }

    int bits, value;
    do {
        *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
        bits = *seed >> 17;
        value = bits % bound;
    } while(bits - value + (bound - 1) < 0);
    return value;
}

unsigned char extract(const unsigned int heightMap[], int id)
{
    return (heightMap[id / 5] >> ((id % 5) * 6)) & 0b111111U;
}

void increase(unsigned int heightMap[], int id, int val)
{
    heightMap[id / 5] += val << ((id % 5) * 6);
}
