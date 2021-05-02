#define MASK ((1UL << 48UL) - 1UL)
#define MUL 0x5DEECE66DUL
#define ADD 0xBUL

#define WANTED_CACTUS_HEIGHT 22

int nextInt(ulong* seed);
int next(ulong* seed, short bits);
int nextIntUnknown(ulong* seed, short bound);

uchar extract(const uint heightMap[], int id);
void increase(uint heightMap[], int id, int val);

kernel void crack(global int *data, global ulong* answer)
{
    int id = get_global_id(0);
    ulong originalSeed = (((ulong)data[0] * (ulong)data[1] + (ulong)id) << 4) | data[8];
    ulong seed = originalSeed;
    short position = -1;
    short posMap;
    short posX, posY, posZ;
    short initialPosX, initialPosY, initialPosZ;
    uchar top = data[7] + FLOOR_LEVEL;

    uint heightMap[171];

    for (short i = 0; i < 171; i++) {
        heightMap[i] = 0;
    }

    for (short i = 0; i < 10; i++) {
        if (WANTED_CACTUS_HEIGHT - top > 9 * (10 - i))
            return;

        initialPosX = next(&seed, 4) + 8;
        initialPosZ = next(&seed, 4) + 8;

        initialPosY = nextIntUnknown(&seed, extract(heightMap, initialPosX + initialPosZ * 32) * 2 + 2);

        if (initialPosY + 3 <= FLOOR_LEVEL && initialPosY - 3 >= 0) {
            seed = (seed * 256682821044977UL + 233843537749372UL) & MASK;
            continue;
        }
        
        if (initialPosY - 3 > top + 1) {
            for (int j = 0; j < 10; j++) {
                seed = (seed * 76790647859193UL + 25707281917278UL) & MASK;
                nextIntUnknown(&seed, nextInt(&seed) + 1);
            }
            continue;
        }
        
#pragma unroll (1)
        for (short a = 0; a < 10; a++) {
            posX = initialPosX + next(&seed, 3) - next(&seed, 3);
            posY = initialPosY + next(&seed, 2) - next(&seed, 2);
            posZ = initialPosZ + next(&seed, 3) - next(&seed, 3);
            posMap = posX + posZ * 32;

            if (position == -1 && posY > FLOOR_LEVEL && posY <= FLOOR_LEVEL + data[7] + 1) {
                if (posMap == data[3]) {
                    position = 0;
                } else if (posMap == data[4]) {
                    position = 1;
                } else if (posMap == data[5]) {
                    position = 2;
                }

                if (position != -1) {
                    int bit = (int)((originalSeed >> 4) & 1);

                    if ((data[6] == position) ^ (bit == data[9]))
                        return;

                    increase(heightMap, posMap, data[7]);
                }
            }

            if (posY <= extract(heightMap, posMap))
                continue;

            short offset = 1 + nextIntUnknown(&seed, nextInt(&seed) + 1);

            for (uchar j = posY; j < posY + offset; j++) {
                if (posY < 0 ||
                    j >  extract(heightMap, posMap) + 1  ||
                    j <= extract(heightMap, (posMap + 1 ) & 1023) ||
                    j <= extract(heightMap, (posMap - 1 ) & 1023) ||
                    j <= extract(heightMap, (posMap + 32) & 1023) ||
                    j <= extract(heightMap, (posMap - 32) & 1023))
                    continue;
                
                increase(heightMap, posMap, 1);
            }
            top = max(top, extract(heightMap, posMap));
        }

    }
    if (top - FLOOR_LEVEL >= WANTED_CACTUS_HEIGHT) {
        answer[atomic_add(&data[2], 1)] =
                ((ulong)top - FLOOR_LEVEL) << 58UL |
                (((ulong)data[position + 3]) << 48UL) |
                originalSeed;
    }
}

int next(ulong* seed, short bits)
{
    *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
    return *seed >> (48 - bits);
}

int nextInt(ulong* seed)
{
    int bits, value;
    do {
        *seed = (*seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
        bits = *seed >> 17;
        value = bits % 3;
    } while(bits - value + (3 - 1) < 0);
    return value;
}

int nextIntUnknown(ulong* seed, short bound)
{
    if((bound & -bound) == bound) {
        *seed = (*seed * MUL + ADD) & MASK;
        return (int)((bound * (*seed >> 17)) >> 31);
    }

    int bits, value;
    do {
        *seed = (*seed * MUL + ADD) & MASK;
        bits = *seed >> 17;
        value = bits % bound;
    } while(bits - value + (bound - 1) < 0);
    return value;
}

uchar extract(const uint heightMap[], int id)
{
    return FLOOR_LEVEL + ((heightMap[id / 6] >> ((id % 6) * 5)) & 0b11111U);
}

void increase(uint heightMap[], int id, int val)
{
    heightMap[id / 6] += val << ((id % 6) * 5);
}


