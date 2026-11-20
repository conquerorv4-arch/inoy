#include "Tools.h"
#include <random>
#include <openssl/md5.h>
#include <openssl/sha.h>

bool Tools::Read(void *addr, void *buffer, size_t length) {
    if (!addr || !buffer || !length) return false;
    return memcpy(buffer, addr, length) != 0;
}

bool Tools::Write(void *addr, void *buffer, size_t length) {
    if (!addr || !buffer || !length) return false;
    return memcpy(addr, buffer, length) != 0;
}

std::string Tools::RandomString(const int len) {
    static const char chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, sizeof(chars) - 2);
    std::string s;
    s.reserve(len);
    for (int i = 0; i < len; i++) s += chars[dis(gen)];
    return s;
}

std::string Tools::CalcMD5(std::string s) {
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5((unsigned char*)s.c_str(), s.length(), digest);
    char buf[33];
    for (int i = 0; i < MD5_DIGEST_LENGTH; i++)
        sprintf(buf + i * 2, "%02x", digest[i]);
    return std::string(buf);
}

std::string Tools::CalcSHA256(std::string s) {
    unsigned char digest[SHA256_DIGEST_LENGTH];
    SHA256((unsigned char*)s.c_str(), s.length(), digest);
    char buf[65];
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++)
        sprintf(buf + i * 2, "%02x", digest[i]);
    return std::string(buf);
}